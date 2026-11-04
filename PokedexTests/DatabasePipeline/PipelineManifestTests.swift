import DatabasePipelineSupport
import XCTest

final class PipelineManifestTests: XCTestCase {
    private var temporaryDirectory: URL!
    private var crawlersRoot: URL!

    override func setUpWithError() throws {
        temporaryDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("PikaDexPipelineManifestTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true)
        crawlersRoot = temporaryDirectory.appendingPathComponent("PikaDexCrawlers", isDirectory: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: temporaryDirectory)
    }

    func testManifestRoundTripAndValidation() throws {
        let inputURL = temporaryDirectory.appendingPathComponent("input.json")
        try "{}".write(to: inputURL, atomically: true, encoding: .utf8)
        let input = PipelineManifest.SourceInput(
            path: "input.json",
            sha256: try PipelineIO.sha256(of: inputURL),
            format: .json,
            provenance: "reviewed fixture",
            upstreamSources: ["fixture-source.json"],
            responsibleManualStep: "Approve the fixture"
        )
        let manifest = makeManifest(inputs: [input])
        let manifestURL = temporaryDirectory.appendingPathComponent("manifest.json")
        try PipelineIO.writeJSON(manifest, to: manifestURL)

        XCTAssertEqual(try PipelineManifestLoader.load(from: manifestURL), manifest)
        XCTAssertNoThrow(try PipelineIO.verify(
            inputs: [input],
            repositoryRoot: temporaryDirectory,
            crawlersRoot: crawlersRoot
        ))
    }

    func testManifestRejectsUnsupportedVersionDuplicateAndUnsortedPaths() throws {
        let a = PipelineManifest.SourceInput(path: "a.json", sha256: "00", format: .json, provenance: "fixture")
        let b = PipelineManifest.SourceInput(path: "b.json", sha256: "00", format: .json, provenance: "fixture")

        for manifest in [
            PipelineManifest(
                schemaVersion: 999,
                canonicalSnapshotSchemaVersion: 2,
                sourceInputs: [],
                modelInputs: [],
                acquisitionSteps: [],
                toolchain: makeManifest(inputs: []).toolchain
            ),
            makeManifest(inputs: [a, a]),
            makeManifest(inputs: [b, a])
        ] {
            let url = temporaryDirectory.appendingPathComponent(UUID().uuidString + ".json")
            try PipelineIO.writeJSON(manifest, to: url)
            XCTAssertThrowsError(try PipelineManifestLoader.load(from: url))
        }
    }

    func testChecksumMismatchAndMissingFileAreActionable() throws {
        let drift = PipelineManifest.SourceInput(path: "drift.json", sha256: "00", format: .json, provenance: "fixture")
        XCTAssertThrowsError(try PipelineIO.verify(
            inputs: [drift], repositoryRoot: temporaryDirectory, crawlersRoot: crawlersRoot
        )) {
            XCTAssertTrue(String(describing: $0).contains("missing"))
        }

        try "{}".write(
            to: temporaryDirectory.appendingPathComponent("drift.json"),
            atomically: true,
            encoding: .utf8
        )
        XCTAssertThrowsError(try PipelineIO.verify(
            inputs: [drift], repositoryRoot: temporaryDirectory, crawlersRoot: crawlersRoot
        )) {
            XCTAssertTrue(String(describing: $0).contains("Checksum mismatch"))
        }
    }

    func testReviewedSourceChangeIsAcceptedAfterManifestChecksumUpdate() throws {
        let inputURL = temporaryDirectory.appendingPathComponent("input.json")
        try "{\"value\":1}".write(to: inputURL, atomically: true, encoding: .utf8)
        let pinned = PipelineManifest.SourceInput(
            path: "input.json",
            sha256: try PipelineIO.sha256(of: inputURL),
            format: .json,
            provenance: "reviewed fixture",
            responsibleManualStep: "Review updated input"
        )
        let manifestURL = temporaryDirectory.appendingPathComponent("manifest.json")
        try PipelineIO.writeJSON(makeManifest(inputs: [pinned]), to: manifestURL)
        try "{\"value\":2}".write(to: inputURL, atomically: true, encoding: .utf8)

        XCTAssertThrowsError(try PipelineIO.preflightReviewedInputs(
            [pinned], repositoryRoot: temporaryDirectory, crawlersRoot: crawlersRoot
        ))
        let reviewedUpdate = PipelineManifest.SourceInput(
            path: "input.json",
            sha256: try PipelineIO.sha256(of: inputURL),
            format: .json,
            provenance: "reviewed fixture with approved value change",
            responsibleManualStep: "Review updated input"
        )
        try PipelineIO.writeJSON(makeManifest(inputs: [reviewedUpdate]), to: manifestURL)

        XCTAssertNoThrow(try PipelineManifestLoader.load(from: manifestURL))
        XCTAssertNoThrow(try PipelineIO.preflightReviewedInputs(
            [reviewedUpdate], repositoryRoot: temporaryDirectory, crawlersRoot: crawlersRoot
        ))
    }

    func testReviewedDelimitedInputPreflightValidatesHeadersAndStableKeys() throws {
        let inputURL = temporaryDirectory.appendingPathComponent("reviewed.tsv")
        try "number\tname\n1\tBulbasaur\n2\tIvysaur\n".write(
            to: inputURL,
            atomically: true,
            encoding: .utf8
        )
        let input = PipelineManifest.SourceInput(
            path: "reviewed.tsv",
            sha256: try PipelineIO.sha256(of: inputURL),
            format: .tsv,
            provenance: "reviewed Numbers export",
            delimiter: "\t",
            requiredHeaders: ["number", "name"],
            rowIdentity: .init(kind: .uniqueKey, columns: ["number"]),
            orderingSemantics: "Rows are reviewed in ascending number order",
            upstreamSources: ["Research/Pokemon.numbers"],
            manualDocument: "Research/Pokemon.numbers",
            manualWorksheet: "Table 1",
            responsibleManualStep: "Review and export the Pokemon table"
        )

        XCTAssertFalse(
            try PipelineIO.preflightReviewedInputs(
                [input], repositoryRoot: temporaryDirectory, crawlersRoot: crawlersRoot
            )
                .contains(where: { $0.severity == .error })
        )

        try "number\tname\n1\tBulbasaur\n1\tIvysaur\n".write(
            to: inputURL,
            atomically: true,
            encoding: .utf8
        )
        let duplicate = PipelineManifest.SourceInput(
            path: "reviewed.tsv",
            sha256: try PipelineIO.sha256(of: inputURL),
            format: .tsv,
            provenance: "reviewed Numbers export",
            delimiter: "\t",
            requiredHeaders: ["number", "name"],
            rowIdentity: .init(kind: .uniqueKey, columns: ["number"]),
            orderingSemantics: "Rows are reviewed in ascending number order",
            responsibleManualStep: "Review and export the Pokemon table"
        )
        let duplicateFindings = try PipelineIO.preflightReviewedInputs(
            [duplicate],
            repositoryRoot: temporaryDirectory,
            crawlersRoot: crawlersRoot
        )
        XCTAssertTrue(duplicateFindings.contains(where: { $0.code == "duplicate_unique_identity" }))
    }

    func testPositionalPreflightAcceptsLegacyBlankHeaderAndRejectsMissingRequiredField() throws {
        let inputURL = temporaryDirectory.appendingPathComponent("reviewed.tsv")
        try "number\t\n1\tBulbasaur\n".write(to: inputURL, atomically: true, encoding: .utf8)
        let positional = PipelineManifest.SourceInput(
            path: "reviewed.tsv",
            sha256: try PipelineIO.sha256(of: inputURL),
            format: .tsv,
            provenance: "reviewed Numbers export",
            delimiter: "\t",
            requiredHeaders: ["number"],
            rowIdentity: .init(kind: .positionalTable, columns: ["number", "<blank>"]),
            orderingSemantics: "Fixed-width positional baseline",
            responsibleManualStep: "Review and export the Pokemon table"
        )
        let positionalFindings = try PipelineIO.preflightReviewedInputs(
            [positional],
            repositoryRoot: temporaryDirectory,
            crawlersRoot: crawlersRoot
        )
        XCTAssertFalse(positionalFindings.contains(where: { $0.severity == .error }))
        XCTAssertTrue(positionalFindings.contains(where: { $0.code == "legacy_blank_header" }))

        let missing = PipelineManifest.SourceInput(
            path: "reviewed.tsv",
            sha256: try PipelineIO.sha256(of: inputURL),
            format: .tsv,
            provenance: "reviewed Numbers export",
            delimiter: "\t",
            requiredHeaders: ["number", "name"],
            rowIdentity: .init(kind: .orderedMultiset),
            orderingSemantics: "File order retained",
            responsibleManualStep: "Review and export the Pokemon table"
        )
        XCTAssertTrue(
            try PipelineIO.preflightReviewedInputs(
                [missing], repositoryRoot: temporaryDirectory, crawlersRoot: crawlersRoot
            )
                .contains(where: { $0.code == "missing_required_field" && $0.severity == .error })
        )
    }

    private func makeManifest(inputs: [PipelineManifest.SourceInput]) -> PipelineManifest {
        .init(
            schemaVersion: 4,
            canonicalSnapshotSchemaVersion: 2,
            sourceInputs: inputs,
            modelInputs: [],
            acquisitionSteps: [],
            toolchain: .init(
                xcode: "test",
                swiftLanguageMode: "5",
                python: "test",
                acquisitionRequirements: "Crawlers/requirements.txt"
            )
        )
    }
}
