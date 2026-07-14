import CoreData
import Foundation
import PokedexCore

/// Explicit loader paths parsed by the `DatabaseLoader` command-line tool.
public struct DatabaseLoaderOptions: Equatable, Sendable {
    public let repositoryRoot: URL
    public let inputRoot: URL
    public let outputDatabase: URL

    public init(repositoryRoot: URL, inputRoot: URL, outputDatabase: URL) throws {
        self.repositoryRoot = repositoryRoot.standardizedFileURL
        self.inputRoot = inputRoot.standardizedFileURL
        self.outputDatabase = outputDatabase.standardizedFileURL
        try PipelinePath.validateCandidateOutput(outputDatabase, repositoryRoot: repositoryRoot)
    }

    public static func parse(_ arguments: [String]) throws -> Self {
        var values = [String: String]()
        var index = 0
        while index < arguments.count {
            let flag = arguments[index]
            guard ["--repository-root", "--input-root", "--output-database"].contains(flag),
                  index + 1 < arguments.count else {
                throw PipelineError.usage(
                    "Usage: DatabaseLoader --repository-root <path> --input-root <path> --output-database <path>"
                )
            }
            values[flag] = arguments[index + 1]
            index += 2
        }
        guard let repositoryRoot = values["--repository-root"],
              let inputRoot = values["--input-root"],
              let outputDatabase = values["--output-database"] else {
            throw PipelineError.usage(
                "Usage: DatabaseLoader --repository-root <path> --input-root <path> --output-database <path>"
            )
        }
        return try .init(
            repositoryRoot: URL(fileURLWithPath: repositoryRoot, isDirectory: true),
            inputRoot: URL(fileURLWithPath: inputRoot, isDirectory: true),
            outputDatabase: URL(fileURLWithPath: outputDatabase)
        )
    }
}

private let validNameCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "♂♀"))

public func sanitizedName(_ name: String) -> String {
    String(name.lowercased(with: Locale(identifier: "en_US_POSIX")).unicodeScalars.filter {
        validNameCharacters.contains($0)
    })
}

public func sanitizedItemName(_ name: String) -> String { sanitizedName(name) }

public func sanitizedMoveName(_ moveName: String) -> String {
    switch sanitizedName(moveName) {
    case "faintattack": return "feintattack"
    case "hijumpkick": return "highjumpkick"
    case "smellingsalt": return "smellingsalts"
    case "vicegrip": return "visegrip"
    case let value: return value
    }
}

/// Loader-only file and Core Data helpers shared through the tooling framework.
public enum Helper {
    private static var options: DatabaseLoaderOptions?

    public static func configure(_ options: DatabaseLoaderOptions) {
        self.options = options
    }

    public static func loadContainer(removeExistingContainer: Bool = true) -> NSPersistentContainer {
        guard let options else {
            preconditionFailure("DatabaseLoader paths were not configured")
        }
        guard let modelURL = Bundle.pokedexCore.url(forResource: "Pokedex", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            preconditionFailure("Authoritative compiled Pokedex model is unavailable")
        }

        do {
            try PipelinePath.validateCandidateOutput(options.outputDatabase, repositoryRoot: options.repositoryRoot)
            try FileManager.default.createDirectory(
                at: options.outputDatabase.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            if removeExistingContainer {
                try removeCandidateStore(at: options.outputDatabase)
            }
        } catch {
            preconditionFailure("Could not prepare isolated candidate store: \(error)")
        }

        let container = NSPersistentContainer(name: "Pokedex", managedObjectModel: model)
        let description = NSPersistentStoreDescription(url: options.outputDatabase)
        description.type = NSSQLiteStoreType
        description.shouldAddStoreAsynchronously = false
        container.persistentStoreDescriptions = [description]

        var loadError: Error?
        container.loadPersistentStores { _, error in loadError = error }
        if let loadError {
            preconditionFailure("Could not load isolated candidate store: \(loadError.localizedDescription)")
        }
        return container
    }

    public static func close(_ container: NSPersistentContainer) throws {
        try container.viewContext.performAndWait {
            if container.viewContext.hasChanges {
                try container.viewContext.save()
            }
        }
        for store in container.persistentStoreCoordinator.persistentStores {
            try container.persistentStoreCoordinator.remove(store)
        }
    }

    public static func loadJSONData(from filename: String) -> Data {
        let url = inputURL(for: filename)
        do {
            return try Data(contentsOf: url)
        } catch {
            preconditionFailure("Could not read manifest-declared input \(filename): \(error.localizedDescription)")
        }
    }

    public static func loadJSON(from filename: String) -> Any {
        do {
            return try JSONSerialization.jsonObject(with: loadJSONData(from: filename), options: .fragmentsAllowed)
        } catch {
            preconditionFailure("Could not parse JSON input \(filename): \(error.localizedDescription)")
        }
    }

    public static func loadTSV(from filename: String) -> [[String: String]] {
        let url = inputURL(for: filename)
        let contents: String
        do {
            contents = try String(contentsOf: url, encoding: .utf8)
        } catch {
            preconditionFailure("Could not read TSV input \(filename): \(error.localizedDescription)")
        }

        let lines = contents
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .split(separator: "\n", omittingEmptySubsequences: true)
            .map(String.init)
        guard let first = lines.first, lines.count > 1 else {
            preconditionFailure("TSV input has no data rows: \(filename)")
        }
        let header = first.components(separatedBy: "\t")
        return lines.dropFirst().enumerated().map { offset, line in
            let components = line.components(separatedBy: "\t")
            guard components.count == header.count else {
                preconditionFailure(
                    "TSV column mismatch in \(filename) at data row \(offset + 1): expected \(header.count), found \(components.count)"
                )
            }
            return zip(header, components).reduce(into: [String: String]()) {
                $0[$1.0] = $1.1
            }
        }
    }

    public static func loadExternalLinksTSV(from filename: String) -> [String: [String: String]] {
        var result = [String: [String: String]]()
        for row in loadTSV(from: filename) {
            guard let name = row["name"] else {
                preconditionFailure("External-link input is missing the name column: \(filename)")
            }
            // Source files are ordered by generation and deliberately repeat
            // renamed items; the last checked-in row is the reviewed override.
            result[sanitizedMoveName(name)] = row
        }
        return result
    }

    public static func sanitizedURL(from string: String) -> URL? {
        URLComponents(string: string.replacingOccurrences(of: "\"", with: ""))?.url
    }

    private static func inputURL(for filename: String) -> URL {
        guard let options else { preconditionFailure("DatabaseLoader paths were not configured") }
        let relativePath: String
        if filename.hasPrefix("Data/") {
            relativePath = "Crawlers/" + filename
        } else if filename.hasPrefix("Research/") {
            relativePath = filename
        } else {
            preconditionFailure("Undocumented loader input namespace: \(filename)")
        }
        do {
            let url = try PipelinePath.resolve(relativePath, under: options.inputRoot)
            guard FileManager.default.fileExists(atPath: url.path) else {
                throw PipelineError.missingPrerequisite("Loader input is missing: \(relativePath)")
            }
            return url
        } catch {
            preconditionFailure(String(describing: error))
        }
    }

    private static func removeCandidateStore(at url: URL) throws {
        for candidate in [url, URL(fileURLWithPath: url.path + "-wal"), URL(fileURLWithPath: url.path + "-shm")] {
            if FileManager.default.fileExists(atPath: candidate.path) {
                try FileManager.default.removeItem(at: candidate)
            }
        }
    }
}

public extension String {
    func removingQuotes() -> String { replacingOccurrences(of: "\"", with: "") }

    mutating func removeQuotes() { self = removingQuotes() }

    func removingDiacritics() -> String {
        folding(options: .diacriticInsensitive, locale: Locale(identifier: "en_US_POSIX"))
    }
}
