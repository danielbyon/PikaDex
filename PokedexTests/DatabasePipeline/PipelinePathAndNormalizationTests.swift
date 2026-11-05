import DatabasePipelineSupport
import XCTest

final class PipelinePathAndNormalizationTests: XCTestCase {
    private var fixtureRoot: URL!
    private var root: URL!
    private var crawlersRoot: URL!

    override func setUpWithError() throws {
        fixtureRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent("PikaDexPipelinePathTests-\(UUID().uuidString)", isDirectory: true)
        root = fixtureRoot.appendingPathComponent("PikaDex", isDirectory: true)
        crawlersRoot = fixtureRoot.appendingPathComponent("PikaDexCrawlers", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        try FileManager.default.createDirectory(
            at: crawlersRoot.appendingPathComponent("Data", isDirectory: true),
            withIntermediateDirectories: true
        )
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: fixtureRoot)
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

    func testCrawlerSourceMappingRejectsTraversalSymlinkEscapeAndOutputOverlap() throws {
        let source = crawlersRoot.appendingPathComponent("Data/value.json")
        let escaped = fixtureRoot.appendingPathComponent("outside.json")
        try "{}".write(to: source, atomically: true, encoding: .utf8)
        try "{}".write(to: escaped, atomically: true, encoding: .utf8)

        XCTAssertEqual(
            try PipelinePath.resolveSourceInput(
                "Crawlers/Data/value.json",
                repositoryRoot: root,
                crawlersRoot: crawlersRoot
            ),
            source
        )
        XCTAssertThrowsError(try PipelinePath.resolveSourceInput(
            "Crawlers/../outside.json",
            repositoryRoot: root,
            crawlersRoot: crawlersRoot
        ))
        XCTAssertThrowsError(try PipelinePath.resolveSourceInput(
            "Crawlers/Cached/site.json",
            repositoryRoot: root,
            crawlersRoot: crawlersRoot
        ))
        try FileManager.default.createSymbolicLink(at: crawlersRoot.appendingPathComponent("Data/escape.json"), withDestinationURL: escaped)

        XCTAssertThrowsError(try PipelinePath.resolveSourceInput(
            "Crawlers/Data/escape.json",
            repositoryRoot: root,
            crawlersRoot: crawlersRoot
        ))
        XCTAssertThrowsError(try PipelinePath.validateCrawlerRoot(
            crawlersRoot,
            repositoryRoot: root,
            outputRoot: crawlersRoot.appendingPathComponent("build/output")
        ))
        let nestedCrawlerRoot = root.appendingPathComponent("nested/PikaDexCrawlers", isDirectory: true)
        try FileManager.default.createDirectory(
            at: nestedCrawlerRoot.appendingPathComponent("Data", isDirectory: true),
            withIntermediateDirectories: true
        )
        XCTAssertThrowsError(try PipelinePath.validateCrawlerRoot(
            nestedCrawlerRoot,
            repositoryRoot: root,
            outputRoot: root.appendingPathComponent("build/output")
        ))

        let missingRoot = fixtureRoot.appendingPathComponent("missing", isDirectory: true)
        XCTAssertThrowsError(try DatabasePipelineOptions.parse(
            ["generate", "--repository-root", root.path, "--crawlers-root", missingRoot.path],
            currentDirectory: root,
            environment: [:]
        )) { error in
            XCTAssertTrue(String(describing: error).contains("PIKADEX_CRAWLERS_ROOT"))
            XCTAssertTrue(String(describing: error).contains("--crawlers-root"))
        }
    }

    func testPipelineOptionsUseCrawlerRootFlagEnvironmentAndSiblingDefault() throws {
        let environmentRoot = fixtureRoot.appendingPathComponent("EnvironmentCrawlers", isDirectory: true)
        try FileManager.default.createDirectory(at: environmentRoot.appendingPathComponent("Data"), withIntermediateDirectories: true)
        let fromEnvironment = try DatabasePipelineOptions.parse(
            ["verify", "--repository-root", root.path],
            currentDirectory: root,
            environment: ["PIKADEX_CRAWLERS_ROOT": environmentRoot.path]
        )
        XCTAssertEqual(fromEnvironment.crawlersRoot, environmentRoot.standardizedFileURL.resolvingSymlinksInPath())

        let fromArgument = try DatabasePipelineOptions.parse(
            ["verify", "--repository-root", root.path, "--crawlers-root", crawlersRoot.path],
            currentDirectory: root,
            environment: ["PIKADEX_CRAWLERS_ROOT": environmentRoot.path]
        )
        XCTAssertEqual(fromArgument.crawlersRoot, crawlersRoot.standardizedFileURL.resolvingSymlinksInPath())

        let fromSibling = try DatabasePipelineOptions.parse(
            ["verify", "--repository-root", root.path],
            currentDirectory: root,
            environment: [:]
        )
        XCTAssertEqual(fromSibling.crawlersRoot, crawlersRoot.standardizedFileURL.resolvingSymlinksInPath())
    }

    func testNormalizationCreatesDerivedCopiesWithoutMutatingPinnedInputs() throws {
        let jsonURL = crawlersRoot.appendingPathComponent("Data/value.json")
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
            crawlersRoot: crawlersRoot,
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

    func testCrawlerInputPreflightChecksThePinnedHashAtItsExternalSourcePath() throws {
        let source = crawlersRoot.appendingPathComponent("Data/reviewed.json")
        let original = Data(#"{"record":"reviewed"}"#.utf8)
        try original.write(to: source)
        let input = PipelineManifest.SourceInput(
            path: "Crawlers/Data/reviewed.json",
            sha256: try PipelineIO.sha256(of: source),
            format: .json,
            provenance: "external fixture"
        )

        let findings = try PipelineIO.preflightReviewedInputs(
            [input],
            repositoryRoot: root,
            crawlersRoot: crawlersRoot
        )
        XCTAssertFalse(findings.contains(where: { $0.severity == .error }))

        try Data(#"{"record":"changed"}"#.utf8).write(to: source)
        XCTAssertThrowsError(try PipelineIO.preflightReviewedInputs(
            [input],
            repositoryRoot: root,
            crawlersRoot: crawlersRoot
        )) { error in
            XCTAssertTrue(String(describing: error).contains("Checksum mismatch for Crawlers/Data/reviewed.json"))
        }
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
