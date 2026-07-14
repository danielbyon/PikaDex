import DatabasePipelineSupport
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
            .appendingPathComponent("PikaDexPipelineCoordinatorTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root.appendingPathComponent("Scripts/DataPipeline"), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: root.appendingPathComponent("Pokedex.xcodeproj"), withIntermediateDirectories: true)
        try "{}".write(to: root.appendingPathComponent("input.json"), atomically: true, encoding: .utf8)
        let manifest = PipelineManifest(
            schemaVersion: 3,
            canonicalSnapshotSchemaVersion: 2,
            sourceInputs: [
                .init(
                    path: "input.json",
                    sha256: try PipelineIO.sha256(of: root.appendingPathComponent("input.json")),
                    format: .json,
                    provenance: "fixture"
                )
            ],
            committedArtifacts: [],
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
            schemaVersion: 3,
            canonicalSnapshotSchemaVersion: 2,
            sourceInputs: [
                .init(
                    path: "input.json",
                    sha256: try PipelineIO.sha256(of: inputURL),
                    format: .json,
                    provenance: "reviewed fixture"
                )
            ],
            committedArtifacts: [],
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
