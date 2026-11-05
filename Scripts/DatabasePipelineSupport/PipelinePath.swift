import Foundation

/// Repository-root-safe path resolution for offline pipeline tools.
public enum PipelinePath {
    public static let databaseResourceDirectory = "Modules/PokedexCore/Resources/Database"
    public static let manifest = "Scripts/DataPipeline/pipeline-manifest.json"
    public static let crawlerSourcePrefix = "Crawlers/"

    public static func isRepositoryRelative(_ path: String) -> Bool {
        guard !path.isEmpty, !path.hasPrefix("/"), !path.hasPrefix("~") else { return false }
        let components = NSString(string: path).pathComponents
        return !components.contains("..") && !components.contains(".")
    }

    public static func resolve(_ path: String, under root: URL) throws -> URL {
        guard isRepositoryRelative(path) else {
            throw PipelineError.unsafePath("Expected a repository-relative path, received: \(path)")
        }
        let canonicalRoot = root.standardizedFileURL.resolvingSymlinksInPath()
        let candidate = canonicalRoot.appendingPathComponent(path).standardizedFileURL.resolvingSymlinksInPath()
        guard candidate.path == canonicalRoot.path || candidate.path.hasPrefix(canonicalRoot.path + "/") else {
            throw PipelineError.unsafePath("Path escapes repository root: \(path)")
        }
        return candidate
    }

    /// Resolves a reviewed manifest path from the repository that owns its source.
    /// Paths under the legacy `Crawlers/` namespace map to the root of the
    /// separately checked out `PikaDexCrawlers` repository; other paths remain
    /// relative to PikaDex.
    public static func resolveSourceInput(
        _ path: String,
        repositoryRoot: URL,
        crawlersRoot: URL
    ) throws -> URL {
        guard isRepositoryRelative(path) else {
            throw PipelineError.unsafePath("Expected a repository-relative source path, received: \(path)")
        }
        guard path != "Crawlers/Cached", !path.hasPrefix("Crawlers/Cached/") else {
            throw PipelineError.unsafePath("Cached crawler data cannot be used as a reviewed loader input")
        }
        if path.hasPrefix(crawlerSourcePrefix) {
            let packagePath = String(path.dropFirst(crawlerSourcePrefix.count))
            guard !packagePath.isEmpty else {
                throw PipelineError.unsafePath("Crawler source path must name a file below Crawlers/")
            }
            return try resolve(packagePath, under: crawlersRoot)
        }
        return try resolve(path, under: repositoryRoot)
    }

    /// Confirms that the external crawler checkout is complete and isolated
    /// from both PikaDex and the pipeline's generated output.
    @discardableResult
    public static func validateCrawlerRoot(
        _ crawlersRoot: URL,
        repositoryRoot: URL,
        outputRoot: URL
    ) throws -> URL {
        let fileManager = FileManager.default
        let canonicalRepository = repositoryRoot.standardizedFileURL.resolvingSymlinksInPath()
        let canonicalCrawlers = crawlersRoot.standardizedFileURL.resolvingSymlinksInPath()
        var isDirectory = ObjCBool(false)
        guard fileManager.fileExists(atPath: canonicalCrawlers.path, isDirectory: &isDirectory),
              isDirectory.boolValue else {
            throw PipelineError.missingPrerequisite(
                "PikaDexCrawlers checkout is missing at \(canonicalCrawlers.path). Clone https://github.com/danielbyon/PikaDexCrawlers beside PikaDex, set PIKADEX_CRAWLERS_ROOT, or pass --crawlers-root."
            )
        }
        guard !pathsOverlap(canonicalRepository.path, canonicalCrawlers.path) else {
            throw PipelineError.unsafePath("PikaDex and PikaDexCrawlers must be separate, non-overlapping checkouts")
        }

        let dataDirectory = try resolve("Data", under: canonicalCrawlers)
        var hasDataDirectory = ObjCBool(false)
        guard fileManager.fileExists(atPath: dataDirectory.path, isDirectory: &hasDataDirectory),
              hasDataDirectory.boolValue else {
            throw PipelineError.missingPrerequisite(
                "PikaDexCrawlers checkout at \(canonicalCrawlers.path) is incomplete: Data/ is missing. Check out the pinned source listed in Scripts/DataPipeline/crawler-source.json."
            )
        }

        let canonicalOutput = outputRoot.standardizedFileURL.resolvingSymlinksInPath()
        guard !pathsOverlap(canonicalCrawlers.path, canonicalOutput.path) else {
            throw PipelineError.unsafePath("Pipeline output cannot overlap the PikaDexCrawlers source checkout")
        }
        return canonicalCrawlers
    }

    private static func pathsOverlap(_ lhs: String, _ rhs: String) -> Bool {
        lhs == rhs || lhs.hasPrefix(rhs + "/") || rhs.hasPrefix(lhs + "/")
    }

    public static func validateCandidateOutput(_ output: URL, repositoryRoot: URL) throws {
        let canonicalOutput = output.standardizedFileURL.resolvingSymlinksInPath()
        let databaseDirectory = try resolve(databaseResourceDirectory, under: repositoryRoot)
        guard canonicalOutput.path != databaseDirectory.path,
              !canonicalOutput.path.hasPrefix(databaseDirectory.path + "/") else {
            throw PipelineError.unsafePath("Candidate output cannot resolve inside the generated database resource directory")
        }

        let resources = try resolve("Modules/PokedexCore/Resources", under: repositoryRoot)
        guard canonicalOutput.path != resources.path,
              !canonicalOutput.path.hasPrefix(resources.path + "/") else {
            throw PipelineError.unsafePath("Candidate output cannot resolve inside committed resources")
        }
    }

    public static func validateDerivedOutputRoot(_ output: URL, repositoryRoot: URL) throws {
        try validateCandidateOutput(output, repositoryRoot: repositoryRoot)
        let canonicalOutput = output.standardizedFileURL.resolvingSymlinksInPath()
        let canonicalRoot = repositoryRoot.standardizedFileURL.resolvingSymlinksInPath()
        guard canonicalOutput.path != canonicalRoot.path else {
            throw PipelineError.unsafePath("Pipeline output cannot be the repository root")
        }
        if canonicalOutput.path.hasPrefix(canonicalRoot.path + "/") {
            let buildDirectory = canonicalRoot.appendingPathComponent("build", isDirectory: true)
            guard canonicalOutput.path == buildDirectory.path ||
                    canonicalOutput.path.hasPrefix(buildDirectory.path + "/") else {
                throw PipelineError.unsafePath("Repository-local pipeline output must be under build/")
            }
        }
    }

    public static func repositoryRoot(startingAt start: URL) throws -> URL {
        var current = start.standardizedFileURL
        while current.path != "/" {
            let project = current.appendingPathComponent("Pokedex.xcodeproj")
            let manifestURL = current.appendingPathComponent(manifest)
            if FileManager.default.fileExists(atPath: project.path),
               FileManager.default.fileExists(atPath: manifestURL.path) {
                return current
            }
            current.deleteLastPathComponent()
        }
        throw PipelineError.missingPrerequisite("Could not locate the PikaDex repository root")
    }
}

public enum PipelineError: Error, CustomStringConvertible, Equatable {
    case usage(String)
    case missingPrerequisite(String)
    case invalidManifest(String)
    case unsafePath(String)
    case inputDrift(String)
    case generation(String)
    case validation(String)
    case semanticDrift(String)
    case acquisitionBlocked(String)

    public var description: String {
        switch self {
        case let .usage(message),
             let .missingPrerequisite(message),
             let .invalidManifest(message),
             let .unsafePath(message),
             let .inputDrift(message),
             let .generation(message),
             let .validation(message),
             let .semanticDrift(message),
             let .acquisitionBlocked(message):
            return message
        }
    }

    public var exitCode: Int32 {
        switch self {
        case .usage, .missingPrerequisite, .invalidManifest, .unsafePath, .inputDrift, .acquisitionBlocked:
            return 2
        case .generation:
            return 3
        case .validation:
            return 4
        case .semanticDrift:
            return 5
        }
    }
}
