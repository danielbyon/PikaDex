import Foundation

/// Repository-root-safe path resolution for offline pipeline tools.
public enum PipelinePath {
    public static let committedDatabaseDirectory = "Modules/PokedexCore/Resources/Database"
    public static let manifest = "Scripts/DataPipeline/pipeline-manifest.json"

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

    public static func validateCandidateOutput(_ output: URL, repositoryRoot: URL) throws {
        let canonicalOutput = output.standardizedFileURL.resolvingSymlinksInPath()
        let committedDirectory = try resolve(committedDatabaseDirectory, under: repositoryRoot)
        guard canonicalOutput.path != committedDirectory.path,
              !canonicalOutput.path.hasPrefix(committedDirectory.path + "/") else {
            throw PipelineError.unsafePath("Candidate output cannot resolve inside the committed database resource directory")
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
