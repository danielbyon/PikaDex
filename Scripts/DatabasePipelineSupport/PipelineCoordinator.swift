import Foundation
import Darwin
import PokedexCore

public enum PipelineCommand: Equatable, Sendable {
    case generate
    case verify
    case normalize
    case validate(database: URL)
    case compare(candidate: URL, baseline: URL)
    case acquire(identifier: String, networkEnabled: Bool)
}

public struct DatabasePipelineOptions: Equatable, Sendable {
    public let command: PipelineCommand
    public let repositoryRoot: URL
    public let crawlersRoot: URL
    public let outputRoot: URL

    public static func parse(
        _ arguments: [String],
        currentDirectory: URL,
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) throws -> Self {
        var arguments = arguments
        let commandName = arguments.first ?? "verify"
        if !arguments.isEmpty { arguments.removeFirst() }

        var repositoryRoot: URL?
        var crawlersRoot: URL?
        var outputRoot: URL?
        var database: URL?
        var baseline: URL?
        var crawler: String?
        var networkEnabled = false
        var index = 0
        while index < arguments.count {
            switch arguments[index] {
            case "--repository-root":
                guard index + 1 < arguments.count else { throw PipelineError.usage("--repository-root requires a path") }
                repositoryRoot = URL(fileURLWithPath: arguments[index + 1], isDirectory: true)
                index += 2
            case "--crawlers-root":
                guard index + 1 < arguments.count else { throw PipelineError.usage("--crawlers-root requires a path") }
                crawlersRoot = URL(fileURLWithPath: arguments[index + 1], isDirectory: true)
                index += 2
            case "--output-dir":
                guard index + 1 < arguments.count else { throw PipelineError.usage("--output-dir requires a path") }
                outputRoot = URL(fileURLWithPath: arguments[index + 1], isDirectory: true)
                index += 2
            case "--database", "--candidate":
                guard index + 1 < arguments.count else { throw PipelineError.usage("\(arguments[index]) requires a path") }
                database = URL(fileURLWithPath: arguments[index + 1])
                index += 2
            case "--baseline":
                guard index + 1 < arguments.count else { throw PipelineError.usage("--baseline requires a path") }
                baseline = URL(fileURLWithPath: arguments[index + 1])
                index += 2
            case "--crawler":
                guard index + 1 < arguments.count else { throw PipelineError.usage("--crawler requires an identifier") }
                crawler = arguments[index + 1]
                index += 2
            case "--network":
                networkEnabled = true
                index += 1
            case let argument:
                throw PipelineError.usage("Unknown pipeline argument: \(argument)")
            }
        }

        let root = try repositoryRoot ?? PipelinePath.repositoryRoot(startingAt: currentDirectory)
        let output = outputRoot ?? root.appendingPathComponent("build/data-pipeline-artifacts", isDirectory: true)
        try PipelinePath.validateDerivedOutputRoot(output, repositoryRoot: root)
        let crawlerRoot = crawlersRoot
            ?? environment["PIKADEX_CRAWLERS_ROOT"].map { URL(fileURLWithPath: $0, isDirectory: true) }
            ?? root.standardizedFileURL.resolvingSymlinksInPath()
                .deletingLastPathComponent()
                .appendingPathComponent("PikaDexCrawlers", isDirectory: true)

        let command: PipelineCommand
        switch commandName {
        case "generate": command = .generate
        case "verify": command = .verify
        case "normalize": command = .normalize
        case "validate":
            guard let database else { throw PipelineError.usage("validate requires --database <path>") }
            command = .validate(database: database)
        case "compare":
            guard let database, let baseline else {
                throw PipelineError.usage("compare requires --candidate <path> and --baseline <path>")
            }
            command = .compare(candidate: database, baseline: baseline)
        case "acquire":
            guard let crawler else { throw PipelineError.usage("acquire requires --crawler <identifier>") }
            command = .acquire(identifier: crawler, networkEnabled: networkEnabled)
        default:
            throw PipelineError.usage("Unknown command \(commandName). Expected generate, verify, normalize, validate, compare, or acquire")
        }
        let validatedCrawlerRoot: URL
        switch command {
        case .generate, .verify, .normalize, .acquire:
            validatedCrawlerRoot = try PipelinePath.validateCrawlerRoot(
                crawlerRoot,
                repositoryRoot: root,
                outputRoot: output
            )
        case .validate, .compare:
            validatedCrawlerRoot = crawlerRoot.standardizedFileURL
        }
        return .init(
            command: command,
            repositoryRoot: root,
            crawlersRoot: validatedCrawlerRoot,
            outputRoot: output
        )
    }
}

public struct PipelineSummary: Codable, Equatable, Sendable {
    public let status: String
    public let phases: [Phase]

    public struct Phase: Codable, Equatable, Sendable {
        public let name: String
        public let status: String
        public let detail: String
    }
}

/// Deterministic evidence produced by an optional crawler staging run.
public struct AcquisitionReport: Codable, Equatable, Sendable {
    public let crawler: String
    public let status: String
    public let stagedOutputs: [String]
    public let requiredNextStep: String
}

public struct PipelineCoordinator {
    private let processRunner: any PipelineProcessRunning
    private let toolDirectory: URL?

    public init(
        processRunner: any PipelineProcessRunning = PipelineProcessRunner(),
        toolDirectory: URL? = nil
    ) {
        self.processRunner = processRunner
        self.toolDirectory = toolDirectory
    }

    public func run(_ options: DatabasePipelineOptions) throws {
        let manifestURL = try PipelinePath.resolve(PipelinePath.manifest, under: options.repositoryRoot)
        let manifest = try PipelineManifestLoader.load(from: manifestURL)
        switch options.command {
        case .generate:
            try executePipeline(options: options, manifest: manifest, installGeneratedDatabase: true)
        case .verify:
            try executePipeline(options: options, manifest: manifest, installGeneratedDatabase: false)
        case .normalize:
            let findings = try preflight(
                manifest: manifest,
                repositoryRoot: options.repositoryRoot,
                crawlersRoot: options.crawlersRoot
            )
            guard !findings.contains(where: { $0.severity == .error }) else {
                throw PipelineError.inputDrift("Reviewed loader-input preflight failed")
            }
            let destination = options.outputRoot.appendingPathComponent("normalized-inputs", isDirectory: true)
            try replaceDerivedDirectory(destination, repositoryRoot: options.repositoryRoot)
            try PipelineIO.normalize(
                inputs: manifest.sourceInputs,
                repositoryRoot: options.repositoryRoot,
                crawlersRoot: options.crawlersRoot,
                destinationRoot: destination
            )
        case let .validate(database):
            let (snapshot, issues) = try CanonicalSnapshotBuilder.build(databaseURL: database)
            let report = try DatabaseValidationReport(databaseRole: "candidate", snapshot: snapshot, issues: issues)
            try PipelineIO.writeJSON(report, to: options.outputRoot.appendingPathComponent("reports/validation.json"))
            try PipelineIO.writeValidationSummary(
                report,
                to: options.outputRoot.appendingPathComponent("reports/validation.txt")
            )
            guard report.passed else {
                throw PipelineError.validation("Candidate database failed validation with \(report.issues.count) issue(s)")
            }
        case let .compare(candidate, baseline):
            try compare(candidate: candidate, baseline: baseline, options: options)
        case let .acquire(identifier, networkEnabled):
            try acquire(
                identifier: identifier,
                networkEnabled: networkEnabled,
                manifest: manifest,
                options: options
            )
        }
    }

    private func executePipeline(
        options: DatabasePipelineOptions,
        manifest: PipelineManifest,
        installGeneratedDatabase: Bool
    ) throws {
        // This path deliberately contains no acquisition call or network flag.
        let normalized = options.outputRoot.appendingPathComponent("normalized-inputs", isDirectory: true)
        let candidateDirectory = options.outputRoot.appendingPathComponent("candidate", isDirectory: true)
        let reports = options.outputRoot.appendingPathComponent("reports", isDirectory: true)
        try replaceDerivedDirectory(reports, repositoryRoot: options.repositoryRoot)
        let findings = try preflight(
            manifest: manifest,
            repositoryRoot: options.repositoryRoot,
            crawlersRoot: options.crawlersRoot
        )
        let preflightReport = ReviewedInputPreflightReport(findings: findings)
        try PipelineIO.writeJSON(preflightReport, to: reports.appendingPathComponent("preflight.json"))
        try PipelineIO.writePreflightSummary(preflightReport, to: reports.appendingPathComponent("preflight.txt"))
        guard preflightReport.passed else {
            throw PipelineError.inputDrift("Reviewed loader-input preflight failed; see preflight reports")
        }

        for directory in [normalized, candidateDirectory] {
            try replaceDerivedDirectory(directory, repositoryRoot: options.repositoryRoot)
        }
        try PipelineIO.normalize(
            inputs: manifest.sourceInputs,
            repositoryRoot: options.repositoryRoot,
            crawlersRoot: options.crawlersRoot,
            destinationRoot: normalized
        )

        let executableDirectory = toolDirectory ?? Bundle.main.executableURL!.deletingLastPathComponent()
        let loader = executableDirectory.appendingPathComponent("DatabaseLoader")
        let validator = executableDirectory.appendingPathComponent("DatabaseValidator")
        for tool in [loader, validator] where !FileManager.default.isExecutableFile(atPath: tool.path) {
            throw PipelineError.missingPrerequisite("Required tooling product is missing: \(tool.lastPathComponent)")
        }

        let candidate = candidateDirectory.appendingPathComponent("Pokedex.sqlite")
        let loaderStatus = try processRunner.run(
            executable: loader,
            arguments: [
                "--repository-root", options.repositoryRoot.path,
                "--input-root", normalized.path,
                "--output-database", candidate.path
            ],
            workingDirectory: nil,
            environment: [:]
        )
        guard loaderStatus == 0 else {
            throw PipelineError.generation("DatabaseLoader exited with status \(loaderStatus)")
        }
        try SQLiteDatabase.prepareForInstallation(at: candidate)
        try SQLiteDatabase.verifyIntegrity(at: candidate)

        let validationReport = reports.appendingPathComponent("validation.json")
        let validationSummary = reports.appendingPathComponent("validation.txt")
        let validatorStatus = try processRunner.run(
            executable: validator,
            arguments: [
                "--database", candidate.path,
                "--report", validationReport.path,
                "--summary", validationSummary.path
            ],
            workingDirectory: nil,
            environment: [:]
        )
        guard validatorStatus == 0 else {
            throw PipelineError.validation(
                "DatabaseValidator exited with status \(validatorStatus); see reports/validation.json and reports/validation.txt"
            )
        }
        guard FileManager.default.fileExists(atPath: validationReport.path),
              FileManager.default.fileExists(atPath: validationSummary.path) else {
            throw PipelineError.validation(
                "DatabaseValidator exited successfully without producing deterministic reports"
            )
        }

        var previousResourceBackup: URL?
        if installGeneratedDatabase {
            let resourceDirectory = try PipelinePath.resolve(
                PipelinePath.databaseResourceDirectory,
                under: options.repositoryRoot
            )
            previousResourceBackup = try DatabaseInstaller.install(
                candidate: candidate,
                resourceDirectory: resourceDirectory
            )
        }

        var phases = [
            PipelineSummary.Phase(name: "preflight", status: "passed", detail: "Reviewed source checksums, input contracts, and compiled model checksums match the manifest"),
            PipelineSummary.Phase(name: "normalize", status: "passed", detail: "Derived input copies were created"),
            PipelineSummary.Phase(name: "generate", status: "passed", detail: "DatabaseLoader created an isolated SQLite candidate"),
            PipelineSummary.Phase(name: "validate", status: "passed", detail: "SQLite integrity, Core Data compatibility, dataset coverage, and required relationships passed")
        ]
        if installGeneratedDatabase {
            let backupDetail = previousResourceBackup.map {
                "; prior database resources retained at \($0.path)"
            } ?? ""
            phases.append(.init(
                name: "install",
                status: "passed",
                detail: "Validated Pokedex.sqlite was installed as a closed, self-contained resource\(backupDetail)"
            ))
        }
        try writeSummary(.init(status: "passed", phases: phases), outputRoot: options.outputRoot)
    }

    private func preflight(
        manifest: PipelineManifest,
        repositoryRoot: URL,
        crawlersRoot: URL
    ) throws -> [ValidationIssue] {
        let findings = try PipelineIO.preflightReviewedInputs(
            manifest.sourceInputs,
            repositoryRoot: repositoryRoot,
            crawlersRoot: crawlersRoot
        )
        try PipelineIO.verify(artifacts: manifest.modelInputs, repositoryRoot: repositoryRoot)
        guard Game.allDatasets.map(\.rawValue).count == Set(Game.allDatasets.map(\.rawValue)).count,
              Game.allDatasets.contains(.national),
              Game.releasedGameMetadata.count + 1 == Game.allDatasets.count else {
            throw PipelineError.invalidManifest("Authoritative compiled dataset catalog is incomplete or inconsistent")
        }
        return findings
    }

    private func compare(candidate: URL, baseline: URL, options: DatabasePipelineOptions) throws {
        let baselineEvaluation = try evaluate(database: baseline)
        let candidateEvaluation = try evaluate(database: candidate)
        let report = try SemanticComparisonReport(
            baseline: baselineEvaluation.snapshot,
            candidate: candidateEvaluation.snapshot,
            baselineIssues: baselineEvaluation.issues,
            candidateIssues: candidateEvaluation.issues
        )
        try PipelineIO.writeJSON(
            report,
            to: options.outputRoot.appendingPathComponent("reports/comparison.json")
        )
        guard report.validationCompatible else {
            throw PipelineError.validation(
                "Candidate introduced new validation errors or severity increases; see reports/comparison.json"
            )
        }
        guard report.matches else {
            throw PipelineError.semanticDrift(
                "Candidate database differs from the explicitly supplied baseline; see reports/comparison.json"
            )
        }
    }

    private func evaluate(database: URL) throws -> (
        snapshot: CanonicalDatabaseSnapshot,
        issues: [ValidationIssue]
    ) {
        let (snapshot, issues) = try CanonicalSnapshotBuilder.build(databaseURL: database)
        return (snapshot, issues)
    }

    private func acquire(
        identifier: String,
        networkEnabled: Bool,
        manifest: PipelineManifest,
        options: DatabasePipelineOptions
    ) throws {
        guard networkEnabled else {
            throw PipelineError.acquisitionBlocked("Acquisition requires the explicit --network flag")
        }
        guard let step = manifest.acquisitionSteps.first(where: { $0.identifier == identifier }) else {
            throw PipelineError.acquisitionBlocked("Crawler is not declared in the curated acquisition manifest: \(identifier)")
        }
        guard step.verified else {
            throw PipelineError.acquisitionBlocked(
                step.blocker ?? "Crawler \(identifier) has not been individually verified and cannot run"
            )
        }

        let stage = options.outputRoot.appendingPathComponent("acquisition/\(identifier)", isDirectory: true)
        try replaceDerivedDirectory(stage, repositoryRoot: options.repositoryRoot)
        let crawlerDirectory = stage.appendingPathComponent("Crawlers", isDirectory: true)
        try FileManager.default.createDirectory(at: crawlerDirectory, withIntermediateDirectories: true)
        let sourceDirectory = options.crawlersRoot
        let scriptURL = try PipelinePath.resolve(step.script, under: sourceDirectory)
        guard FileManager.default.fileExists(atPath: scriptURL.path) else {
            throw PipelineError.missingPrerequisite("Manifest-declared crawler script is missing: \(step.script)")
        }
        for url in try FileManager.default.contentsOfDirectory(at: sourceDirectory, includingPropertiesForKeys: nil)
            where ["py", "txt"].contains(url.pathExtension) {
            let source = try PipelinePath.resolve(url.lastPathComponent, under: sourceDirectory)
            try FileManager.default.copyItem(
                at: source,
                to: crawlerDirectory.appendingPathComponent(url.lastPathComponent)
            )
        }

        let python = URL(fileURLWithPath: "/usr/bin/env")
        let status = try processRunner.run(
            executable: python,
            arguments: ["python3", step.script],
            workingDirectory: crawlerDirectory,
            environment: ["PIKADEX_CRAWLER_ALLOWED_HOSTS": step.allowedHosts.joined(separator: ",")]
        )
        guard status == 0 else {
            throw PipelineError.generation("Crawler \(identifier) exited with status \(status)")
        }
        for output in step.outputs {
            let url = crawlerDirectory.appendingPathComponent(output)
            guard FileManager.default.fileExists(atPath: url.path) else {
                throw PipelineError.generation("Crawler \(identifier) did not produce declared output \(output)")
            }
        }
        let report = AcquisitionReport(
            crawler: identifier,
            status: "staged",
            stagedOutputs: step.outputs.sorted(),
            requiredNextStep: "Manual reconciliation in the documented Numbers workflow is required; staged crawler output is not a reviewed loader input."
        )
        try PipelineIO.writeJSON(report, to: stage.appendingPathComponent("acquisition.json"))
        let summary = [
            "crawler: \(report.crawler)",
            "status: \(report.status)",
            "required-next-step: \(report.requiredNextStep)"
        ] + report.stagedOutputs.map { "staged-output: \($0)" }
        try (summary.joined(separator: "\n") + "\n").write(
            to: stage.appendingPathComponent("acquisition.txt"),
            atomically: true,
            encoding: .utf8
        )
    }

    private func replaceDerivedDirectory(_ url: URL, repositoryRoot: URL) throws {
        try PipelinePath.validateDerivedOutputRoot(url, repositoryRoot: repositoryRoot)
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    private func writeSummary(_ summary: PipelineSummary, outputRoot: URL) throws {
        try PipelineIO.writeJSON(summary, to: outputRoot.appendingPathComponent("reports/summary.json"))
        let text = (["status: \(summary.status)"] + summary.phases.map {
            "\($0.name): \($0.status) - \($0.detail)"
        }).joined(separator: "\n") + "\n"
        let url = outputRoot.appendingPathComponent("reports/summary.txt")
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try text.write(to: url, atomically: true, encoding: .utf8)
    }
}

/// Checks generated SQLite paths without following symlinks and refuses paths that another process has open.
enum SQLiteFileAccess {
    static func itemType(at url: URL) throws -> mode_t? {
        var information = stat()
        let status = url.path.withCString { lstat($0, &information) }
        guard status == 0 else {
            if errno == ENOENT { return nil }
            throw PipelineError.generation("Could not inspect SQLite path \(url.path): \(String(cString: strerror(errno)))")
        }
        return information.st_mode & S_IFMT
    }

    static func requireClosed(at url: URL) throws {
        guard try itemType(at: url) != nil else { return }
        let process = Process()
        let standardOutput = Pipe()
        let standardError = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/sbin/lsof")
        process.arguments = ["-t", url.path]
        process.standardOutput = standardOutput
        process.standardError = standardError
        do {
            try process.run()
        } catch {
            throw PipelineError.generation("Could not check whether SQLite resource is open: \(error.localizedDescription)")
        }
        process.waitUntilExit()
        let output = String(data: standardOutput.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        let errorOutput = String(data: standardError.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        if process.terminationStatus == 0 {
            let owners = output.split(whereSeparator: { $0.isNewline }).joined(separator: ", ")
            throw PipelineError.generation("Refusing to modify an open SQLite resource \(url.path); process id(s): \(owners)")
        }
        guard process.terminationStatus == 1, errorOutput.isEmpty, output.isEmpty else {
            throw PipelineError.generation("Could not confirm that SQLite resource is closed: \(url.path)")
        }
    }
}

/// Installs one validated SQLite file while keeping any previous database and sidecars together.
enum DatabaseInstaller {
    private static let allowedResourceFiles: Set<String> = [
        "Pokedex.sqlite",
        "Pokedex.sqlite-wal",
        "Pokedex.sqlite-shm",
        "Pokedex.sqlite-journal"
    ]
    private static let minimumFreeSpaceMargin: Int64 = 32 * 1_024 * 1_024

    private struct Identity: Equatable {
        let device: dev_t
        let inode: ino_t
    }

    static func install(
        candidate: URL,
        resourceDirectory: URL,
        afterExchange: ((URL) throws -> Void)? = nil
    ) throws -> URL? {
        let fileManager = FileManager.default
        guard try itemType(at: candidate) == S_IFREG else {
            throw PipelineError.generation("SQLite candidate is missing or is not a regular file: \(candidate.path)")
        }
        try SQLiteFileAccess.requireClosed(at: candidate)
        try requireSelfContained(candidate)
        try SQLiteDatabase.verifyIntegrity(at: candidate)
        try SQLiteFileAccess.requireClosed(at: candidate)

        let parent = resourceDirectory.deletingLastPathComponent()
        try fileManager.createDirectory(at: parent, withIntermediateDirectories: true)
        guard try itemType(at: parent) == S_IFDIR else {
            throw PipelineError.generation("Database resource parent is not a real directory: \(parent.path)")
        }

        let targetType = try itemType(at: resourceDirectory)
        let hadPreviousDirectory = targetType != nil
        guard targetType == nil || targetType == S_IFDIR else {
            throw PipelineError.generation("Refusing to replace a non-directory or symbolic link: \(resourceDirectory.path)")
        }
        let originalIdentity = hadPreviousDirectory ? try identity(at: resourceDirectory) : nil
        if hadPreviousDirectory {
            try validateResourceDirectory(resourceDirectory)
            try requireDatabaseClosed(in: resourceDirectory)
        }

        try verifyAvailableSpace(for: candidate, on: parent)
        let stagingDirectory = parent.appendingPathComponent(
            ".Database.install-\(UUID().uuidString)",
            isDirectory: true
        )
        do {
            try fileManager.createDirectory(at: stagingDirectory, withIntermediateDirectories: false)
        } catch {
            throw PipelineError.generation("Could not create SQLite installation staging directory: \(error.localizedDescription)")
        }

        var exchanged = false
        do {
            let stagedDatabase = stagingDirectory.appendingPathComponent("Pokedex.sqlite")
            try fileManager.copyItem(at: candidate, to: stagedDatabase)
            try requireSelfContained(stagedDatabase)
            guard try PipelineIO.sha256(of: stagedDatabase) == PipelineIO.sha256(of: candidate) else {
                throw PipelineError.generation("Staged SQLite candidate hash differs from the validated candidate")
            }
            try SQLiteDatabase.verifyIntegrity(at: stagedDatabase)
            try synchronize(stagedDatabase)
            try synchronize(stagingDirectory)

            if hadPreviousDirectory {
                guard try identity(at: resourceDirectory) == originalIdentity else {
                    throw PipelineError.generation("Database resource directory changed during installation; existing files were left in place")
                }
                try validateResourceDirectory(resourceDirectory)
                try requireDatabaseClosed(in: resourceDirectory)
                try atomicSwap(resourceDirectory, stagingDirectory)
            } else {
                guard try itemType(at: resourceDirectory) == nil else {
                    throw PipelineError.generation("Database resource directory appeared during installation; existing files were left in place")
                }
                try renameExclusively(stagingDirectory, resourceDirectory)
            }
            exchanged = true
            try afterExchange?(stagingDirectory)

            let installedDatabase = resourceDirectory.appendingPathComponent("Pokedex.sqlite")
            try requireSelfContained(installedDatabase)
            try SQLiteDatabase.verifyIntegrity(at: installedDatabase)
            guard try PipelineIO.sha256(of: installedDatabase) == PipelineIO.sha256(of: candidate) else {
                throw PipelineError.generation("Installed SQLite database does not match the validated candidate")
            }
            try synchronize(installedDatabase)
            try synchronize(parent)
            return hadPreviousDirectory ? stagingDirectory : nil
        } catch {
            if exchanged {
                do {
                    if hadPreviousDirectory {
                        try atomicSwap(resourceDirectory, stagingDirectory)
                    } else {
                        try renameExclusively(resourceDirectory, stagingDirectory)
                    }
                    try synchronize(parent)
                    exchanged = false
                } catch {
                    throw PipelineError.generation(
                        "SQLite installation failed and automatic rollback also failed. The previous resource directory is preserved at \(stagingDirectory.path); stop the app and follow the recovery procedure in Scripts/DataPipeline/README.md. Install error: \(error.localizedDescription)"
                    )
                }
            }
            if !exchanged {
                try? fileManager.removeItem(at: stagingDirectory)
            }
            throw PipelineError.generation("SQLite installation failed; previous database resources were restored: \(error.localizedDescription)")
        }
    }

    private static func itemType(at url: URL) throws -> mode_t? {
        var information = stat()
        let status = url.path.withCString { lstat($0, &information) }
        guard status == 0 else {
            if errno == ENOENT { return nil }
            throw PipelineError.generation("Could not inspect database path \(url.path): \(String(cString: strerror(errno)))")
        }
        return information.st_mode & S_IFMT
    }

    private static func identity(at url: URL) throws -> Identity {
        var information = stat()
        let status = url.path.withCString { lstat($0, &information) }
        guard status == 0, information.st_mode & S_IFMT == S_IFDIR else {
            throw PipelineError.generation("Database resource directory disappeared or changed type: \(url.path)")
        }
        return Identity(device: information.st_dev, inode: information.st_ino)
    }

    private static func validateResourceDirectory(_ directory: URL) throws {
        for name in try FileManager.default.contentsOfDirectory(atPath: directory.path) {
            guard allowedResourceFiles.contains(name) else {
                throw PipelineError.generation("Refusing database installation because the resource directory contains an unrecognized file: \(name)")
            }
            let url = directory.appendingPathComponent(name)
            guard try itemType(at: url) == S_IFREG else {
                throw PipelineError.generation("Refusing database installation because a database resource is not a regular file: \(url.path)")
            }
        }
    }

    private static func requireSelfContained(_ database: URL) throws {
        for suffix in ["-wal", "-shm", "-journal"] {
            let sidecar = URL(fileURLWithPath: database.path + suffix)
            guard try itemType(at: sidecar) == nil else {
                throw PipelineError.generation("Refusing SQLite installation while a candidate sidecar exists: \(sidecar.path)")
            }
        }
    }

    private static func requireDatabaseClosed(in directory: URL) throws {
        for name in allowedResourceFiles.sorted() {
            let databaseFile = directory.appendingPathComponent(name)
            try SQLiteFileAccess.requireClosed(at: databaseFile)
        }
    }

    private static func verifyAvailableSpace(for candidate: URL, on volumeRoot: URL) throws {
        let attributes = try FileManager.default.attributesOfItem(atPath: candidate.path)
        guard let size = (attributes[.size] as? NSNumber)?.int64Value else {
            throw PipelineError.generation("Could not determine the generated SQLite database size")
        }
        let filesystem = try FileManager.default.attributesOfFileSystem(forPath: volumeRoot.path)
        guard let available = (filesystem[.systemFreeSize] as? NSNumber)?.int64Value else {
            throw PipelineError.generation("Could not determine free space for the database resource volume")
        }
        let required = size.addingReportingOverflow(max(minimumFreeSpaceMargin, size / 100))
        guard !required.overflow, available >= required.partialValue else {
            throw PipelineError.generation("Insufficient free space to stage the SQLite database safely: need about \(required.partialValue) bytes, have \(available)")
        }
    }

    private static func synchronize(_ url: URL) throws {
        let descriptor = url.path.withCString { open($0, O_RDONLY) }
        guard descriptor >= 0 else {
            throw PipelineError.generation("Could not open path for durable SQLite installation: \(url.path)")
        }
        defer { _ = close(descriptor) }
        guard fsync(descriptor) == 0 else {
            throw PipelineError.generation("Could not sync SQLite installation path \(url.path): \(String(cString: strerror(errno)))")
        }
    }

    private static func atomicSwap(_ first: URL, _ second: URL) throws {
        let status = first.path.withCString { firstPath in
            second.path.withCString { secondPath in
                renameatx_np(AT_FDCWD, firstPath, AT_FDCWD, secondPath, UInt32(RENAME_SWAP))
            }
        }
        guard status == 0 else {
            throw PipelineError.generation("Atomic database directory exchange failed: \(String(cString: strerror(errno)))")
        }
    }

    private static func renameExclusively(_ source: URL, _ destination: URL) throws {
        let status = source.path.withCString { sourcePath in
            destination.path.withCString { destinationPath in
                renameatx_np(AT_FDCWD, sourcePath, AT_FDCWD, destinationPath, UInt32(RENAME_EXCL))
            }
        }
        guard status == 0 else {
            throw PipelineError.generation("Atomic database installation failed without changing the existing path: \(String(cString: strerror(errno)))")
        }
    }
}
