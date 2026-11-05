@testable import DatabasePipelineSupport
import SQLite3
import XCTest

final class PipelineCoordinatorTests: XCTestCase {
    private final class ProcessRunner: PipelineProcessRunning {
        var statuses: [Int32]
        private(set) var invocations = [String]()
        let onRun: ((URL, [String], URL?, [String: String]) throws -> Void)?

        init(
            statuses: [Int32],
            onRun: ((URL, [String], URL?, [String: String]) throws -> Void)? = nil
        ) {
            self.statuses = statuses
            self.onRun = onRun
        }

        func run(
            executable: URL,
            arguments: [String],
            workingDirectory: URL?,
            environment: [String: String]
        ) throws -> Int32 {
            invocations.append(executable.lastPathComponent)
            try onRun?(executable, arguments, workingDirectory, environment)
            return statuses.removeFirst()
        }
    }

    private var root: URL!

    override func setUpWithError() throws {
        root = FileManager.default.temporaryDirectory
            .appendingPathComponent("PikaDex Pipeline Coordinator Tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root.appendingPathComponent("Scripts/DataPipeline"), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: root.appendingPathComponent("Pokedex.xcodeproj"), withIntermediateDirectories: true)
        try "{}".write(to: root.appendingPathComponent("input.json"), atomically: true, encoding: .utf8)
        let manifest = PipelineManifest(
            schemaVersion: 4,
            canonicalSnapshotSchemaVersion: 2,
            sourceInputs: [
                .init(
                    path: "input.json",
                    sha256: try PipelineIO.sha256(of: root.appendingPathComponent("input.json")),
                    format: .json,
                    provenance: "fixture"
                )
            ],
            modelInputs: [],
            acquisitionSteps: [
                .init(
                    identifier: "blocked",
                    script: "Blocked.py",
                    outputs: [],
                    allowedHosts: ["example.invalid"],
                    verified: false,
                    blocker: "not verified"
                )
            ],
            toolchain: .init(xcode: "test", swiftLanguageMode: "5", python: "test", acquisitionRequirements: "requirements.txt")
        )
        try PipelineIO.writeJSON(manifest, to: root.appendingPathComponent(PipelinePath.manifest))
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: root)
    }

    private func makeTools() throws -> URL {
        let tools = root.appendingPathComponent("tools")
        try FileManager.default.createDirectory(at: tools, withIntermediateDirectories: true)
        for name in ["DatabaseLoader", "DatabaseValidator"] {
            try FileManager.default.createSymbolicLink(
                at: tools.appendingPathComponent(name),
                withDestinationURL: URL(fileURLWithPath: "/usr/bin/true")
            )
        }
        return tools
    }

    private func makeSuccessfulRunner(statuses: [Int32]) -> ProcessRunner {
        ProcessRunner(statuses: statuses) { executable, arguments, _, _ in
            if executable.lastPathComponent == "DatabaseLoader" {
                let candidatePath = try XCTUnwrap(Self.value(after: "--output-database", in: arguments))
                try Self.createSQLiteDatabase(at: URL(fileURLWithPath: candidatePath))
            } else if executable.lastPathComponent == "DatabaseValidator" {
                let reportPath = try XCTUnwrap(Self.value(after: "--report", in: arguments))
                let summaryPath = try XCTUnwrap(Self.value(after: "--summary", in: arguments))
                try Data("{\"status\":\"passed\"}".utf8).write(
                    to: URL(fileURLWithPath: reportPath),
                    options: .atomic
                )
                try "status: passed\\n".write(
                    to: URL(fileURLWithPath: summaryPath),
                    atomically: true,
                    encoding: .utf8
                )
            }
        }
    }

    private static func value(after flag: String, in arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: flag), arguments.indices.contains(index + 1) else {
            return nil
        }
        return arguments[index + 1]
    }

    private static func createSQLiteDatabase(at url: URL) throws {
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        var database: OpaquePointer?
        let openStatus = sqlite3_open_v2(
            url.path,
            &database,
            SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX,
            nil
        )
        guard openStatus == SQLITE_OK, let database else {
            let message = database.map { String(cString: sqlite3_errmsg($0)) } ?? "could not allocate connection"
            if let database { sqlite3_close_v2(database) }
            throw NSError(domain: "PipelineCoordinatorTests.SQLite", code: Int(openStatus), userInfo: [
                NSLocalizedDescriptionKey: message
            ])
        }
        defer { sqlite3_close_v2(database) }
        let sqlStatus = sqlite3_exec(
            database,
            "CREATE TABLE sample (value TEXT); INSERT INTO sample VALUES ('candidate');",
            nil,
            nil,
            nil
        )
        guard sqlStatus == SQLITE_OK else {
            throw NSError(
                domain: "PipelineCoordinatorTests.SQLite",
                code: Int(sqlStatus),
                userInfo: [NSLocalizedDescriptionKey: String(cString: sqlite3_errmsg(database))]
            )
        }
    }

    func testVerifyNeverInvokesAcquisitionAndPropagatesGenerationFailure() throws {
        let tools = root.appendingPathComponent("tools")
        try FileManager.default.createDirectory(at: tools, withIntermediateDirectories: true)
        for name in ["DatabaseLoader", "DatabaseValidator"] {
            try FileManager.default.createSymbolicLink(
                at: tools.appendingPathComponent(name),
                withDestinationURL: URL(fileURLWithPath: "/usr/bin/true")
            )
        }
        let runner = ProcessRunner(statuses: [3])
        let options = try DatabasePipelineOptions.parse(
            ["verify", "--repository-root", root.path, "--output-dir", root.appendingPathComponent("build/output").path],
            currentDirectory: root
        )

        XCTAssertThrowsError(try PipelineCoordinator(processRunner: runner, toolDirectory: tools).run(options)) {
            XCTAssertEqual(($0 as? PipelineError)?.exitCode, 3)
        }
        XCTAssertEqual(runner.invocations, ["DatabaseLoader"])
    }

    func testVerifyDoesNotNeedOrInstallAnExistingDatabase() throws {
        let options = try DatabasePipelineOptions.parse(
            ["verify", "--repository-root", root.path, "--output-dir", root.appendingPathComponent("build/output").path],
            currentDirectory: root
        )
        let runner = makeSuccessfulRunner(statuses: [0, 0])

        XCTAssertNoThrow(try PipelineCoordinator(processRunner: runner, toolDirectory: try makeTools()).run(options))
        XCTAssertTrue(FileManager.default.fileExists(
            atPath: root.appendingPathComponent("build/output/candidate/Pokedex.sqlite").path
        ))
        XCTAssertFalse(FileManager.default.fileExists(
            atPath: root.appendingPathComponent("Modules/PokedexCore/Resources/Database/Pokedex.sqlite").path
        ))
    }

    func testVerifyRejectsNonzeroValidatorStatusEvenWhenReportsExist() throws {
        let options = try DatabasePipelineOptions.parse(
            ["verify", "--repository-root", root.path, "--output-dir", root.appendingPathComponent("build/output").path],
            currentDirectory: root
        )
        let runner = makeSuccessfulRunner(statuses: [0, 7])

        XCTAssertThrowsError(try PipelineCoordinator(processRunner: runner, toolDirectory: try makeTools()).run(options)) {
            XCTAssertTrue(($0 as? PipelineError)?.description.contains("DatabaseValidator exited with status 7") == true)
        }
    }

    func testGenerateBuildsAndInstallsAValidatedDatabase() throws {
        let options = try? DatabasePipelineOptions.parse(
            ["generate", "--repository-root", root.path, "--output-dir", root.appendingPathComponent("build/output").path],
            currentDirectory: root
        )
        XCTAssertNotNil(options, "generate must be an accepted pipeline command")
        guard let options else { return }

        let runner = makeSuccessfulRunner(statuses: [0, 0])
        try PipelineCoordinator(processRunner: runner, toolDirectory: try makeTools()).run(options)

        let installed = root.appendingPathComponent("Modules/PokedexCore/Resources/Database/Pokedex.sqlite")
        XCTAssertTrue(FileManager.default.fileExists(atPath: installed.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: URL(fileURLWithPath: installed.path + "-wal").path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: URL(fileURLWithPath: installed.path + "-shm").path))
        XCTAssertEqual(runner.invocations, ["DatabaseLoader", "DatabaseValidator"])
    }

    func testGenerationFailurePreservesExistingDatabaseAndSidecars() throws {
        let resourceDirectory = root.appendingPathComponent("Modules/PokedexCore/Resources/Database")
        try FileManager.default.createDirectory(at: resourceDirectory, withIntermediateDirectories: true)
        let database = resourceDirectory.appendingPathComponent("Pokedex.sqlite")
        try Self.createSQLiteDatabase(at: database)
        let wal = URL(fileURLWithPath: database.path + "-wal")
        let shm = URL(fileURLWithPath: database.path + "-shm")
        try Data("old wal".utf8).write(to: wal)
        try Data("old shm".utf8).write(to: shm)
        let originalDatabase = try Data(contentsOf: database)
        let originalWAL = try Data(contentsOf: wal)
        let originalSHM = try Data(contentsOf: shm)
        let options = try? DatabasePipelineOptions.parse(
            ["generate", "--repository-root", root.path, "--output-dir", root.appendingPathComponent("build/output").path],
            currentDirectory: root
        )
        XCTAssertNotNil(options, "generate must be an accepted pipeline command")
        guard let options else { return }

        let runner = makeSuccessfulRunner(statuses: [6])
        XCTAssertThrowsError(try PipelineCoordinator(processRunner: runner, toolDirectory: try makeTools()).run(options))

        XCTAssertEqual(try Data(contentsOf: database), originalDatabase)
        XCTAssertEqual(try Data(contentsOf: wal), originalWAL)
        XCTAssertEqual(try Data(contentsOf: shm), originalSHM)
    }

    func testValidationFailurePreservesExistingDatabaseAndSidecars() throws {
        let resourceDirectory = root.appendingPathComponent("Modules/PokedexCore/Resources/Database")
        try FileManager.default.createDirectory(at: resourceDirectory, withIntermediateDirectories: true)
        let database = resourceDirectory.appendingPathComponent("Pokedex.sqlite")
        try Self.createSQLiteDatabase(at: database)
        let wal = URL(fileURLWithPath: database.path + "-wal")
        let shm = URL(fileURLWithPath: database.path + "-shm")
        try Data("old wal".utf8).write(to: wal)
        try Data("old shm".utf8).write(to: shm)
        let originalDatabase = try Data(contentsOf: database)
        let originalWAL = try Data(contentsOf: wal)
        let originalSHM = try Data(contentsOf: shm)
        let options = try? DatabasePipelineOptions.parse(
            ["generate", "--repository-root", root.path, "--output-dir", root.appendingPathComponent("build/output").path],
            currentDirectory: root
        )
        XCTAssertNotNil(options, "generate must be an accepted pipeline command")
        guard let options else { return }

        let runner = makeSuccessfulRunner(statuses: [0, 7])
        XCTAssertThrowsError(try PipelineCoordinator(processRunner: runner, toolDirectory: try makeTools()).run(options)) {
            XCTAssertTrue(($0 as? PipelineError)?.description.contains("DatabaseValidator exited with status 7") == true)
        }

        XCTAssertEqual(try Data(contentsOf: database), originalDatabase)
        XCTAssertEqual(try Data(contentsOf: wal), originalWAL)
        XCTAssertEqual(try Data(contentsOf: shm), originalSHM)
    }

    func testValidatedCandidateReplacesDatabaseAndSidecarsAsASet() throws {
        let resourceDirectory = root.appendingPathComponent("Modules/PokedexCore/Resources/Database")
        try FileManager.default.createDirectory(at: resourceDirectory, withIntermediateDirectories: true)
        let database = resourceDirectory.appendingPathComponent("Pokedex.sqlite")
        try Self.createSQLiteDatabase(at: database)
        let wal = URL(fileURLWithPath: database.path + "-wal")
        let shm = URL(fileURLWithPath: database.path + "-shm")
        try Data("old wal".utf8).write(to: wal)
        try Data("old shm".utf8).write(to: shm)
        let originalDatabase = try Data(contentsOf: database)
        let originalWAL = try Data(contentsOf: wal)
        let originalSHM = try Data(contentsOf: shm)
        let options = try? DatabasePipelineOptions.parse(
            ["generate", "--repository-root", root.path, "--output-dir", root.appendingPathComponent("build/output").path],
            currentDirectory: root
        )
        XCTAssertNotNil(options, "generate must be an accepted pipeline command")
        guard let options else { return }

        let runner = ProcessRunner(statuses: [0, 0]) { executable, arguments, _, _ in
            if executable.lastPathComponent == "DatabaseLoader" {
                let candidatePath = try XCTUnwrap(Self.value(after: "--output-database", in: arguments))
                try Self.createSQLiteDatabase(at: URL(fileURLWithPath: candidatePath))
            } else {
                XCTAssertEqual(try Data(contentsOf: database), originalDatabase)
                XCTAssertEqual(try Data(contentsOf: wal), originalWAL)
                XCTAssertEqual(try Data(contentsOf: shm), originalSHM)
                let reportPath = try XCTUnwrap(Self.value(after: "--report", in: arguments))
                let summaryPath = try XCTUnwrap(Self.value(after: "--summary", in: arguments))
                try Data("{\"status\":\"passed\"}".utf8).write(to: URL(fileURLWithPath: reportPath), options: .atomic)
                try "status: passed\\n".write(to: URL(fileURLWithPath: summaryPath), atomically: true, encoding: .utf8)
            }
        }

        try PipelineCoordinator(processRunner: runner, toolDirectory: try makeTools()).run(options)

        let backupDirectory = try XCTUnwrap(
            FileManager.default.contentsOfDirectory(
                at: resourceDirectory.deletingLastPathComponent(),
                includingPropertiesForKeys: nil
            ).first { $0.lastPathComponent.hasPrefix(".Database.install-") }
        )
        XCTAssertEqual(try Data(contentsOf: backupDirectory.appendingPathComponent("Pokedex.sqlite")), originalDatabase)
        XCTAssertEqual(try Data(contentsOf: backupDirectory.appendingPathComponent("Pokedex.sqlite-wal")), originalWAL)
        XCTAssertEqual(try Data(contentsOf: backupDirectory.appendingPathComponent("Pokedex.sqlite-shm")), originalSHM)
        XCTAssertFalse(FileManager.default.fileExists(atPath: wal.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: shm.path))
        XCTAssertNoThrow(try SQLiteDatabase.verifyIntegrity(at: database))
    }

    func testPrepareForInstallationRemovesClosedOrphanedSHMSidecar() throws {
        let candidate = root.appendingPathComponent("candidate/Pokedex.sqlite")
        try Self.createSQLiteDatabase(at: candidate)
        let shm = URL(fileURLWithPath: candidate.path + "-shm")
        try Data(repeating: 0, count: 32_768).write(to: shm)

        XCTAssertNoThrow(try SQLiteDatabase.prepareForInstallation(at: candidate))
        XCTAssertFalse(FileManager.default.fileExists(atPath: shm.path))
        XCTAssertNoThrow(try SQLiteDatabase.verifyIntegrity(at: candidate))
    }

    func testPrepareForInstallationRefusesOpenCandidateAndPreservesSHMSidecar() throws {
        let candidate = root.appendingPathComponent("candidate/Pokedex.sqlite")
        try Self.createSQLiteDatabase(at: candidate)
        let shm = URL(fileURLWithPath: candidate.path + "-shm")
        let originalSHM = Data(repeating: 7, count: 32_768)
        try originalSHM.write(to: shm)

        var handle: OpaquePointer?
        XCTAssertEqual(
            sqlite3_open_v2(candidate.path, &handle, SQLITE_OPEN_READONLY | SQLITE_OPEN_FULLMUTEX, nil),
            SQLITE_OK
        )
        defer { if let handle { sqlite3_close(handle) } }

        XCTAssertThrowsError(try SQLiteDatabase.prepareForInstallation(at: candidate)) {
            XCTAssertTrue(String(describing: $0).localizedCaseInsensitiveContains("open"))
        }
        XCTAssertEqual(try Data(contentsOf: shm), originalSHM)
    }

    func testGenerateRejectsInvalidSQLiteBeforeValidationOrInstall() throws {
        let options = try DatabasePipelineOptions.parse(
            ["generate", "--repository-root", root.path, "--output-dir", root.appendingPathComponent("build/output").path],
            currentDirectory: root
        )
        let runner = ProcessRunner(statuses: [0, 0]) { executable, arguments, _, _ in
            if executable.lastPathComponent == "DatabaseLoader" {
                let candidatePath = try XCTUnwrap(Self.value(after: "--output-database", in: arguments))
                try Data("not a SQLite database".utf8).write(to: URL(fileURLWithPath: candidatePath))
            } else {
                XCTFail("An invalid SQLite candidate must fail before DatabaseValidator runs")
            }
        }

        XCTAssertThrowsError(try PipelineCoordinator(processRunner: runner, toolDirectory: try makeTools()).run(options))
        XCTAssertEqual(runner.invocations, ["DatabaseLoader"])
        XCTAssertFalse(FileManager.default.fileExists(
            atPath: root.appendingPathComponent("Modules/PokedexCore/Resources/Database/Pokedex.sqlite").path
        ))
    }

    func testGenerateRefusesAnOpenExistingStoreWithoutChangingItsFiles() throws {
        let resourceDirectory = root.appendingPathComponent("Modules/PokedexCore/Resources/Database")
        try FileManager.default.createDirectory(at: resourceDirectory, withIntermediateDirectories: true)
        let database = resourceDirectory.appendingPathComponent("Pokedex.sqlite")
        try Self.createSQLiteDatabase(at: database)
        let wal = URL(fileURLWithPath: database.path + "-wal")
        let shm = URL(fileURLWithPath: database.path + "-shm")
        try Data("old wal".utf8).write(to: wal)
        try Data("old shm".utf8).write(to: shm)
        let originalDatabase = try Data(contentsOf: database)
        let originalWAL = try Data(contentsOf: wal)
        let originalSHM = try Data(contentsOf: shm)
        var handle: OpaquePointer?
        XCTAssertEqual(sqlite3_open_v2(database.path, &handle, SQLITE_OPEN_READONLY | SQLITE_OPEN_FULLMUTEX, nil), SQLITE_OK)
        defer { if let handle { sqlite3_close(handle) } }

        let options = try DatabasePipelineOptions.parse(
            ["generate", "--repository-root", root.path, "--output-dir", root.appendingPathComponent("build/output").path],
            currentDirectory: root
        )
        XCTAssertThrowsError(try PipelineCoordinator(processRunner: makeSuccessfulRunner(statuses: [0, 0]), toolDirectory: try makeTools()).run(options)) {
            XCTAssertTrue(($0 as? PipelineError)?.description.contains("open") == true)
        }
        XCTAssertEqual(try Data(contentsOf: database), originalDatabase)
        XCTAssertEqual(try Data(contentsOf: wal), originalWAL)
        XCTAssertEqual(try Data(contentsOf: shm), originalSHM)
    }

    func testDatabaseInstallerRollsBackAfterInterruptionFollowingExchange() throws {
        let resourceDirectory = root.appendingPathComponent("Modules/PokedexCore/Resources/Database")
        try FileManager.default.createDirectory(at: resourceDirectory, withIntermediateDirectories: true)
        let database = resourceDirectory.appendingPathComponent("Pokedex.sqlite")
        try Self.createSQLiteDatabase(at: database)
        let wal = URL(fileURLWithPath: database.path + "-wal")
        let shm = URL(fileURLWithPath: database.path + "-shm")
        try Data("old wal".utf8).write(to: wal)
        try Data("old shm".utf8).write(to: shm)
        let originalDatabase = try Data(contentsOf: database)
        let originalWAL = try Data(contentsOf: wal)
        let originalSHM = try Data(contentsOf: shm)
        let candidate = root.appendingPathComponent("candidate/Pokedex.sqlite")
        try Self.createSQLiteDatabase(at: candidate)

        XCTAssertThrowsError(try DatabaseInstaller.install(
            candidate: candidate,
            resourceDirectory: resourceDirectory,
            afterExchange: { _ in throw PipelineError.generation("simulated interruption") }
        ))
        XCTAssertEqual(try Data(contentsOf: database), originalDatabase)
        XCTAssertEqual(try Data(contentsOf: wal), originalWAL)
        XCTAssertEqual(try Data(contentsOf: shm), originalSHM)
    }

    func testAcquisitionRequiresNetworkAndIndividualVerification() throws {
        let coordinator = PipelineCoordinator(processRunner: ProcessRunner(statuses: []), toolDirectory: root)
        for arguments in [
            ["acquire", "--crawler", "blocked", "--repository-root", root.path, "--output-dir", root.appendingPathComponent("build/output").path],
            ["acquire", "--crawler", "blocked", "--network", "--repository-root", root.path, "--output-dir", root.appendingPathComponent("build/output").path]
        ] {
            let options = try DatabasePipelineOptions.parse(arguments, currentDirectory: root)
            XCTAssertThrowsError(try coordinator.run(options)) {
                XCTAssertEqual(($0 as? PipelineError)?.exitCode, 2)
            }
        }
    }

    func testVerifiedAcquisitionRemainsStagedAndReportsManualNumbersRequirement() throws {
        let crawlerSource = root.appendingPathComponent("Crawlers/Allowed.py")
        try FileManager.default.createDirectory(
            at: crawlerSource.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try "# fixture\n".write(to: crawlerSource, atomically: true, encoding: .utf8)
        let inputURL = root.appendingPathComponent("input.json")
        let manifest = PipelineManifest(
            schemaVersion: 4,
            canonicalSnapshotSchemaVersion: 2,
            sourceInputs: [
                .init(
                    path: "input.json",
                    sha256: try PipelineIO.sha256(of: inputURL),
                    format: .json,
                    provenance: "reviewed fixture"
                )
            ],
            modelInputs: [],
            acquisitionSteps: [
                .init(
                    identifier: "allowed",
                    script: "Allowed.py",
                    outputs: ["Data/output.json"],
                    allowedHosts: ["example.invalid"],
                    verified: true,
                    blocker: nil
                )
            ],
            toolchain: .init(
                xcode: "test",
                swiftLanguageMode: "5",
                python: "test",
                acquisitionRequirements: "requirements.txt"
            )
        )
        try PipelineIO.writeJSON(manifest, to: root.appendingPathComponent(PipelinePath.manifest))

        let runner = ProcessRunner(statuses: [0]) { _, _, workingDirectory, _ in
            let stagedOutput = workingDirectory!.appendingPathComponent("Data/output.json")
            try FileManager.default.createDirectory(
                at: stagedOutput.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try "{}".write(to: stagedOutput, atomically: true, encoding: .utf8)
        }
        let output = root.appendingPathComponent("build/output")
        let options = try DatabasePipelineOptions.parse(
            [
                "acquire", "--crawler", "allowed", "--network",
                "--repository-root", root.path,
                "--output-dir", output.path
            ],
            currentDirectory: root
        )
        try PipelineCoordinator(processRunner: runner, toolDirectory: root).run(options)

        let reportURL = output.appendingPathComponent("acquisition/allowed/acquisition.json")
        let report = try JSONDecoder().decode(AcquisitionReport.self, from: Data(contentsOf: reportURL))
        XCTAssertEqual(report.status, "staged")
        XCTAssertTrue(report.requiredNextStep.contains("Manual reconciliation"))
        XCTAssertFalse(FileManager.default.fileExists(atPath: root.appendingPathComponent("Crawlers/Data/output.json").path))
    }
}
