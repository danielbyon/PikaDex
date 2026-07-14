import Foundation
import PokedexCore

public enum PipelineCommand: Equatable, Sendable {
    case verify
    case normalize
    case validate(database: URL)
    case compare(candidate: URL)
    case acquire(identifier: String, networkEnabled: Bool)
}

public struct DatabasePipelineOptions: Equatable, Sendable {
    public let command: PipelineCommand
    public let repositoryRoot: URL
    public let outputRoot: URL

    public static func parse(_ arguments: [String], currentDirectory: URL) throws -> Self {
        var arguments = arguments
        let commandName = arguments.first ?? "verify"
        if !arguments.isEmpty { arguments.removeFirst() }

        var repositoryRoot: URL?
        var outputRoot: URL?
        var database: URL?
        var crawler: String?
        var networkEnabled = false
        var index = 0
        while index < arguments.count {
            switch arguments[index] {
            case "--repository-root":
                guard index + 1 < arguments.count else { throw PipelineError.usage("--repository-root requires a path") }
                repositoryRoot = URL(fileURLWithPath: arguments[index + 1], isDirectory: true)
                index += 2
            case "--output-dir":
                guard index + 1 < arguments.count else { throw PipelineError.usage("--output-dir requires a path") }
                outputRoot = URL(fileURLWithPath: arguments[index + 1], isDirectory: true)
                index += 2
            case "--database", "--candidate":
                guard index + 1 < arguments.count else { throw PipelineError.usage("\(arguments[index]) requires a path") }
                database = URL(fileURLWithPath: arguments[index + 1])
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

        let command: PipelineCommand
        switch commandName {
        case "verify": command = .verify
        case "normalize": command = .normalize
        case "validate":
            guard let database else { throw PipelineError.usage("validate requires --database <path>") }
            command = .validate(database: database)
        case "compare":
            guard let database else { throw PipelineError.usage("compare requires --candidate <path>") }
            command = .compare(candidate: database)
        case "acquire":
            guard let crawler else { throw PipelineError.usage("acquire requires --crawler <identifier>") }
            command = .acquire(identifier: crawler, networkEnabled: networkEnabled)
        default:
            throw PipelineError.usage("Unknown command \(commandName). Expected verify, normalize, validate, compare, or acquire")
        }
        return .init(command: command, repositoryRoot: root, outputRoot: output)
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
        case .verify:
            try verify(options: options, manifest: manifest)
        case .normalize:
            let findings = try preflight(manifest: manifest, repositoryRoot: options.repositoryRoot)
            guard !findings.contains(where: { $0.severity == .error }) else {
                throw PipelineError.inputDrift("Reviewed loader-input preflight failed")
            }
            let destination = options.outputRoot.appendingPathComponent("normalized-inputs", isDirectory: true)
            try replaceDerivedDirectory(destination, repositoryRoot: options.repositoryRoot)
            try PipelineIO.normalize(
                inputs: manifest.sourceInputs,
                repositoryRoot: options.repositoryRoot,
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
        case let .compare(candidate):
            try compare(candidate: candidate, options: options)
        case let .acquire(identifier, networkEnabled):
            try acquire(
                identifier: identifier,
                networkEnabled: networkEnabled,
                manifest: manifest,
                options: options
            )
        }
    }

    private func verify(options: DatabasePipelineOptions, manifest: PipelineManifest) throws {
        // This path deliberately contains no acquisition call or network flag.
        let normalized = options.outputRoot.appendingPathComponent("normalized-inputs", isDirectory: true)
        let candidateDirectory = options.outputRoot.appendingPathComponent("candidate", isDirectory: true)
        let reports = options.outputRoot.appendingPathComponent("reports", isDirectory: true)
        try replaceDerivedDirectory(reports, repositoryRoot: options.repositoryRoot)
        let findings = try preflight(manifest: manifest, repositoryRoot: options.repositoryRoot)
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
        guard FileManager.default.fileExists(atPath: validationReport.path),
              FileManager.default.fileExists(atPath: validationSummary.path) else {
            throw PipelineError.validation(
                "DatabaseValidator exited with status \(validatorStatus) without producing deterministic reports"
            )
        }
        try compare(candidate: candidate, options: options)
        try writeSummary(
            .init(status: "passed", phases: [
                .init(name: "preflight", status: "passed", detail: "Reviewed loader inputs satisfy manifest schema and committed artifacts match"),
                .init(name: "normalize", status: "passed", detail: "Derived input copies created"),
                .init(name: "generate", status: "passed", detail: "Candidate database generated in isolation"),
                .init(name: "validate", status: "passed", detail: "Candidate findings are baseline-compatible"),
                .init(name: "compare", status: "passed", detail: "Candidate matches the committed semantic snapshot")
            ]),
            outputRoot: options.outputRoot
        )
    }

    private func preflight(manifest: PipelineManifest, repositoryRoot: URL) throws -> [ValidationIssue] {
        let findings = try PipelineIO.preflightReviewedInputs(manifest.sourceInputs, repositoryRoot: repositoryRoot)
        try PipelineIO.verify(artifacts: manifest.modelInputs, repositoryRoot: repositoryRoot)
        try PipelineIO.verify(artifacts: manifest.committedArtifacts, repositoryRoot: repositoryRoot)
        guard Game.allDatasets.map(\.rawValue).count == Set(Game.allDatasets.map(\.rawValue)).count,
              Game.allDatasets.contains(.national),
              Game.releasedGameMetadata.count + 1 == Game.allDatasets.count else {
            throw PipelineError.invalidManifest("Authoritative compiled dataset catalog is incomplete or inconsistent")
        }
        return findings
    }

    private func compare(candidate: URL, options: DatabasePipelineOptions) throws {
        let baseline = try PipelinePath.resolve(
            "Modules/PokedexCore/Resources/Database/Pokedex.sqlite",
            under: options.repositoryRoot
        )
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
                "Candidate database differs from the committed canonical snapshot; see reports/comparison.json"
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
        let sourceDirectory = try PipelinePath.resolve("Crawlers", under: options.repositoryRoot)
        for url in try FileManager.default.contentsOfDirectory(at: sourceDirectory, includingPropertiesForKeys: nil)
            where ["py", "txt"].contains(url.pathExtension) {
            try FileManager.default.copyItem(at: url, to: crawlerDirectory.appendingPathComponent(url.lastPathComponent))
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
