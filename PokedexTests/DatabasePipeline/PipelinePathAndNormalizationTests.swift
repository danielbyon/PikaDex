import DatabasePipelineSupport
import XCTest

final class PipelinePathAndNormalizationTests: XCTestCase {
    private var root: URL!

    override func setUpWithError() throws {
        root = FileManager.default.temporaryDirectory
            .appendingPathComponent("PikaDexPipelinePathTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: root)
    }

    func testPathResolutionRejectsAbsoluteTraversalAndCommittedResources() throws {
        XCTAssertFalse(PipelinePath.isRepositoryRelative("/tmp/input"))
        XCTAssertFalse(PipelinePath.isRepositoryRelative("../input"))
        XCTAssertTrue(PipelinePath.isRepositoryRelative("Research/Pokemon.tsv"))
        XCTAssertThrowsError(try PipelinePath.resolve("../input", under: root))

        let committed = root.appendingPathComponent("Modules/PokedexCore/Resources/Database/Pokedex.sqlite")
        XCTAssertThrowsError(try PipelinePath.validateCandidateOutput(committed, repositoryRoot: root))
        XCTAssertThrowsError(try PipelinePath.validateDerivedOutputRoot(root, repositoryRoot: root))
        XCTAssertNoThrow(
            try PipelinePath.validateDerivedOutputRoot(
                root.appendingPathComponent("build/data-pipeline"),
                repositoryRoot: root
            )
        )
    }

    func testNormalizationCreatesDerivedCopiesWithoutMutatingPinnedInputs() throws {
        let jsonURL = root.appendingPathComponent("Crawlers/Data/value.json")
        let tsvURL = root.appendingPathComponent("Research/value.tsv")
        try FileManager.default.createDirectory(at: jsonURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: tsvURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try #"{"z":1,"a":2}"#.write(to: jsonURL, atomically: true, encoding: .utf8)
        try "name\tvalue\r\nB\t2\r\nA\t1\r\n".write(to: tsvURL, atomically: true, encoding: .utf8)
        let originalJSON = try Data(contentsOf: jsonURL)
        let destination = root.appendingPathComponent("build/normalized")

        try PipelineIO.normalize(
            inputs: [
                .init(path: "Crawlers/Data/value.json", sha256: "unused", format: .json, provenance: "fixture"),
                .init(path: "Research/value.tsv", sha256: "unused", format: .tsv, provenance: "fixture")
            ],
            repositoryRoot: root,
            destinationRoot: destination
        )

        XCTAssertEqual(try Data(contentsOf: jsonURL), originalJSON)
        XCTAssertEqual(
            try String(contentsOf: destination.appendingPathComponent("Research/value.tsv"), encoding: .utf8),
            "name\tvalue\nB\t2\nA\t1\n"
        )
        let normalizedJSON = try String(
            contentsOf: destination.appendingPathComponent("Crawlers/Data/value.json"),
            encoding: .utf8
        )
        XCTAssertLessThan(normalizedJSON.range(of: #""a""#)!.lowerBound, normalizedJSON.range(of: #""z""#)!.lowerBound)
    }

    func testLoaderOptionsRequireExplicitSafePaths() throws {
        XCTAssertThrowsError(try DatabaseLoaderOptions.parse([]))
        let options = try DatabaseLoaderOptions.parse([
            "--repository-root", root.path,
            "--input-root", root.appendingPathComponent("build/inputs").path,
            "--output-database", root.appendingPathComponent("build/output/Pokedex.sqlite").path
        ])
        XCTAssertEqual(options.repositoryRoot.path, root.path)
        XCTAssertThrowsError(
            try DatabaseLoaderOptions(
                repositoryRoot: root,
                inputRoot: root,
                outputDatabase: root.appendingPathComponent("Modules/PokedexCore/Resources/Database/Pokedex.sqlite")
            )
        )
    }

    func testLegacyTSVLoaderRetainsLastColumnForCompatibility() throws {
        let inputRoot = root.appendingPathComponent("build/inputs")
        let input = inputRoot.appendingPathComponent("Research/duplicate.tsv")
        try FileManager.default.createDirectory(at: input.deletingLastPathComponent(), withIntermediateDirectories: true)
        try "name\t\t\nvalue\told\tnew\n".write(to: input, atomically: true, encoding: .utf8)
        let options = try DatabaseLoaderOptions(
            repositoryRoot: root,
            inputRoot: inputRoot,
            outputDatabase: root.appendingPathComponent("build/output/Pokedex.sqlite")
        )
        Helper.configure(options)

        XCTAssertEqual(Helper.loadTSV(from: "Research/duplicate.tsv"), [["name": "value", "": "new"]])
    }
}
