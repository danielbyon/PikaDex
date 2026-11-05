import CoreData
import CryptoKit
import Foundation
import SQLite3
import PokedexCore

/// A versioned, deterministic representation of the generated Core Data catalog.
///
/// Core Data object identifiers and SQLite row identifiers are intentionally
/// excluded. Records and relationships use explicit domain key strategies so
/// semantically identical stores compare equal even when SQLite layout differs.
public struct CanonicalDatabaseSnapshot: Codable, Equatable, Sendable {
    public static let schemaVersion = 2

    public let schemaVersion: Int
    public let modelFingerprint: String
    public let datasets: [String]
    public let entities: [Entity]

    public init(modelFingerprint: String, datasets: [String], entities: [Entity]) {
        self.schemaVersion = Self.schemaVersion
        self.modelFingerprint = modelFingerprint
        self.datasets = datasets
        self.entities = entities
    }

    public struct Entity: Codable, Equatable, Sendable {
        public let name: String
        public let records: [Record]

        public init(name: String, records: [Record]) {
            self.name = name
            self.records = records
        }
    }

    public struct Record: Codable, Equatable, Sendable {
        public let key: String
        public let attributes: [Field]
        public let relationships: [Relationship]

        public init(key: String, attributes: [Field], relationships: [Relationship]) {
            self.key = key
            self.attributes = attributes
            self.relationships = relationships
        }
    }

    public struct Field: Codable, Equatable, Sendable {
        public let name: String
        public let value: String

        public init(name: String, value: String) {
            self.name = name
            self.value = value
        }
    }

    public struct Relationship: Codable, Equatable, Sendable {
        public let name: String
        public let targetKeys: [String]

        public init(name: String, targetKeys: [String]) {
            self.name = name
            self.targetKeys = targetKeys
        }
    }

    public var rowCounts: [String: Int] {
        Dictionary(uniqueKeysWithValues: entities.map { ($0.name, $0.records.count) })
    }

    public func digest() throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(self)
        return SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    public func entityDigests() throws -> [String: String] {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        return try Dictionary(uniqueKeysWithValues: entities.map { entity in
            let data = try encoder.encode(entity)
            let digest = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
            return (entity.name, digest)
        })
    }
}

public enum ValidationSeverity: String, Codable, Equatable, Sendable, Comparable {
    case error
    case warning
    case info

    var sortOrder: Int {
        switch self {
        case .error: return 0
        case .warning: return 1
        case .info: return 2
        }
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }

    public func isMoreSevere(than other: Self) -> Bool {
        sortOrder < other.sortOrder
    }
}

public struct ValidationIssue: Codable, Equatable, Sendable, Comparable {
    public let severity: ValidationSeverity
    public let code: String
    public let entity: String
    public let key: String
    public let message: String

    public init(
        severity: ValidationSeverity = .error,
        code: String,
        entity: String,
        key: String,
        message: String
    ) {
        self.severity = severity
        self.code = code
        self.entity = entity
        self.key = key
        self.message = message
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        (lhs.severity, lhs.code, lhs.entity, lhs.key, lhs.message)
            < (rhs.severity, rhs.code, rhs.entity, rhs.key, rhs.message)
    }

    public var baselineIdentity: String {
        [code, entity, key, message].joined(separator: "\u{001F}")
    }
}

public struct DatabaseValidationReport: Codable, Equatable, Sendable {
    public let snapshotSchemaVersion: Int
    public let databaseRole: String
    public let passed: Bool
    public let modelFingerprint: String
    public let semanticDigest: String
    public let rowCounts: [String: Int]
    public let issues: [ValidationIssue]

    public init(
        databaseRole: String,
        snapshot: CanonicalDatabaseSnapshot,
        issues: [ValidationIssue]
    ) throws {
        self.snapshotSchemaVersion = CanonicalDatabaseSnapshot.schemaVersion
        self.databaseRole = databaseRole
        self.passed = !issues.contains(where: { $0.severity == .error })
        self.modelFingerprint = snapshot.modelFingerprint
        self.semanticDigest = try snapshot.digest()
        self.rowCounts = snapshot.rowCounts
        self.issues = issues.sorted()
    }

}

public struct SemanticComparisonReport: Codable, Equatable, Sendable {
    public let snapshotSchemaVersion: Int
    public let matches: Bool
    public let baselineDigest: String
    public let candidateDigest: String
    public let baselineValidationIssueCount: Int
    public let candidateValidationIssueCount: Int
    public let baselineErrorCount: Int
    public let candidateErrorCount: Int
    public let validationCompatible: Bool
    public let newErrors: [ValidationIssue]
    public let severityIncreases: [SeverityIncrease]
    public let semanticEntityChanges: [String]
    public let semanticDifferences: [EntityDifference]
    public let rowCountChanges: [RowCountChange]

    public struct RowCountChange: Codable, Equatable, Sendable, Comparable {
        public let entity: String
        public let baseline: Int
        public let candidate: Int

        public static func < (lhs: Self, rhs: Self) -> Bool { lhs.entity < rhs.entity }
    }

    public struct SeverityIncrease: Codable, Equatable, Sendable, Comparable {
        public let code: String
        public let entity: String
        public let key: String
        public let baseline: ValidationSeverity
        public let candidate: ValidationSeverity

        public static func < (lhs: Self, rhs: Self) -> Bool {
            (lhs.code, lhs.entity, lhs.key, lhs.baseline, lhs.candidate)
                < (rhs.code, rhs.entity, rhs.key, rhs.baseline, rhs.candidate)
        }
    }

    public struct NamedCount: Codable, Equatable, Sendable, Comparable {
        public let name: String
        public let count: Int

        public static func < (lhs: Self, rhs: Self) -> Bool { lhs.name < rhs.name }
    }

    public struct EntityDifference: Codable, Equatable, Sendable, Comparable {
        public let entity: String
        public let addedKeys: Int
        public let removedKeys: Int
        public let changedRecordCount: Int
        public let changedAttributes: [NamedCount]
        public let changedRelationships: [NamedCount]

        public static func < (lhs: Self, rhs: Self) -> Bool { lhs.entity < rhs.entity }
    }

    public init(baseline: CanonicalDatabaseSnapshot, candidate: CanonicalDatabaseSnapshot) throws {
        try self.init(baseline: baseline, candidate: candidate, baselineIssues: [], candidateIssues: [])
    }

    public init(
        baseline: CanonicalDatabaseSnapshot,
        candidate: CanonicalDatabaseSnapshot,
        baselineIssues: [ValidationIssue],
        candidateIssues: [ValidationIssue]
    ) throws {
        let baselineByIdentity = Dictionary(
            baselineIssues.map { ($0.baselineIdentity, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        newErrors = candidateIssues.filter {
            $0.severity == .error && baselineByIdentity[$0.baselineIdentity] == nil
        }.sorted()
        severityIncreases = candidateIssues.compactMap { issue in
            guard let prior = baselineByIdentity[issue.baselineIdentity],
                  issue.severity.isMoreSevere(than: prior.severity) else { return nil }
            return .init(
                code: issue.code,
                entity: issue.entity,
                key: issue.key,
                baseline: prior.severity,
                candidate: issue.severity
            )
        }.sorted()
        validationCompatible = newErrors.isEmpty && severityIncreases.isEmpty
        baselineErrorCount = baselineIssues.filter { $0.severity == .error }.count
        candidateErrorCount = candidateIssues.filter { $0.severity == .error }.count
        semanticDifferences = Self.differenceSummaries(baseline: baseline, candidate: candidate)

        snapshotSchemaVersion = CanonicalDatabaseSnapshot.schemaVersion
        baselineDigest = try baseline.digest()
        candidateDigest = try candidate.digest()
        matches = baselineDigest == candidateDigest
        baselineValidationIssueCount = baselineIssues.count
        candidateValidationIssueCount = candidateIssues.count
        let baselineEntityDigests = try baseline.entityDigests()
        let candidateEntityDigests = try candidate.entityDigests()
        semanticEntityChanges = Set(baselineEntityDigests.keys)
            .union(candidateEntityDigests.keys)
            .filter { baselineEntityDigests[$0] != candidateEntityDigests[$0] }
            .sorted()
        let entities = Set(baseline.rowCounts.keys).union(candidate.rowCounts.keys)
        rowCountChanges = entities.compactMap { entity in
            let old = baseline.rowCounts[entity, default: 0]
            let new = candidate.rowCounts[entity, default: 0]
            return old == new ? nil : .init(entity: entity, baseline: old, candidate: new)
        }.sorted()
    }

    public init(
        baselineDigest: String,
        candidateDigest: String,
        baselineRowCounts: [String: Int],
        candidateRowCounts: [String: Int],
        baselineEntityDigests: [String: String],
        candidateEntityDigests: [String: String],
        baselineValidationIssueCount: Int,
        candidateValidationIssueCount: Int
    ) {
        snapshotSchemaVersion = CanonicalDatabaseSnapshot.schemaVersion
        matches = baselineDigest == candidateDigest
        self.baselineDigest = baselineDigest
        self.candidateDigest = candidateDigest
        self.baselineValidationIssueCount = baselineValidationIssueCount
        self.candidateValidationIssueCount = candidateValidationIssueCount
        baselineErrorCount = 0
        candidateErrorCount = 0
        validationCompatible = true
        newErrors = []
        severityIncreases = []
        semanticDifferences = []
        semanticEntityChanges = Set(baselineEntityDigests.keys)
            .union(candidateEntityDigests.keys)
            .filter { baselineEntityDigests[$0] != candidateEntityDigests[$0] }
            .sorted()
        let entities = Set(baselineRowCounts.keys).union(candidateRowCounts.keys)
        rowCountChanges = entities.compactMap { entity in
            let old = baselineRowCounts[entity, default: 0]
            let new = candidateRowCounts[entity, default: 0]
            return old == new ? nil : .init(entity: entity, baseline: old, candidate: new)
        }.sorted()
    }

    private static func differenceSummaries(
        baseline: CanonicalDatabaseSnapshot,
        candidate: CanonicalDatabaseSnapshot
    ) -> [EntityDifference] {
        let baselineEntities = Dictionary(uniqueKeysWithValues: baseline.entities.map { ($0.name, $0) })
        let candidateEntities = Dictionary(uniqueKeysWithValues: candidate.entities.map { ($0.name, $0) })
        return Set(baselineEntities.keys).union(candidateEntities.keys).compactMap { name in
            let oldRecords = baselineEntities[name]?.records ?? []
            let newRecords = candidateEntities[name]?.records ?? []
            let oldGroups = Dictionary(grouping: oldRecords, by: \.key)
            let newGroups = Dictionary(grouping: newRecords, by: \.key)
            let oldKeys = Set(oldGroups.keys)
            let newKeys = Set(newGroups.keys)
            var changedRecordCount = 0
            var attributeCounts = [String: Int]()
            var relationshipCounts = [String: Int]()

            for key in oldKeys.intersection(newKeys).sorted() {
                let oldGroup = oldGroups[key, default: []]
                let newGroup = newGroups[key, default: []]
                guard oldGroup != newGroup else { continue }
                changedRecordCount += max(oldGroup.count, newGroup.count)
                if oldGroup.count != newGroup.count {
                    attributeCounts["<record-multiplicity>", default: 0] += 1
                }
                for index in 0..<min(oldGroup.count, newGroup.count) {
                    let old = oldGroup[index]
                    let new = newGroup[index]
                    let oldAttributes = Dictionary(uniqueKeysWithValues: old.attributes.map { ($0.name, $0.value) })
                    let newAttributes = Dictionary(uniqueKeysWithValues: new.attributes.map { ($0.name, $0.value) })
                    for field in Set(oldAttributes.keys).union(newAttributes.keys)
                        where oldAttributes[field] != newAttributes[field] {
                        attributeCounts[field, default: 0] += 1
                    }
                    let oldRelationships = Dictionary(
                        uniqueKeysWithValues: old.relationships.map { ($0.name, $0.targetKeys) }
                    )
                    let newRelationships = Dictionary(
                        uniqueKeysWithValues: new.relationships.map { ($0.name, $0.targetKeys) }
                    )
                    for relationship in Set(oldRelationships.keys).union(newRelationships.keys)
                        where oldRelationships[relationship] != newRelationships[relationship] {
                        relationshipCounts[relationship, default: 0] += 1
                    }
                }
            }

            let added = newKeys.subtracting(oldKeys).count
            let removed = oldKeys.subtracting(newKeys).count
            guard added > 0 || removed > 0 || changedRecordCount > 0 else { return nil }
            return .init(
                entity: name,
                addedKeys: added,
                removedKeys: removed,
                changedRecordCount: changedRecordCount,
                changedAttributes: attributeCounts.map { .init(name: $0.key, count: $0.value) }.sorted(),
                changedRelationships: relationshipCounts.map { .init(name: $0.key, count: $0.value) }.sorted()
            )
        }.sorted()
    }
}

enum SQLiteDatabase {
    static func prepareForInstallation(at url: URL) throws {
        do {
            guard try SQLiteFileAccess.itemType(at: url) == S_IFREG else {
                throw PipelineError.generation("SQLite candidate is missing or is not a regular file: \(url.path)")
            }
            try SQLiteFileAccess.requireClosed(at: url)
            try withDatabase(at: url, flags: SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX) { database in
                let checkpoint = try rows("PRAGMA wal_checkpoint(TRUNCATE)", database: database)
                guard let result = checkpoint.first, result.count == 3,
                      Int(result[0]) == 0,
                      let logFrames = Int(result[1]),
                      let checkpointedFrames = Int(result[2]),
                      logFrames < 0 || logFrames == checkpointedFrames else {
                    throw PipelineError.generation("SQLite WAL checkpoint was busy or incomplete")
                }

                let journalMode = try rows("PRAGMA journal_mode=DELETE", database: database)
                guard journalMode.first?.first?.lowercased() == "delete" else {
                    throw PipelineError.generation("SQLite could not switch the candidate to DELETE journal mode")
                }
            }
            try SQLiteFileAccess.requireClosed(at: url)
        } catch {
            throw PipelineError.generation("Could not checkpoint and close the SQLite candidate: \(error)")
        }

        for suffix in ["-wal", "-journal"] {
            let sidecar = URL(fileURLWithPath: url.path + suffix)
            guard try SQLiteFileAccess.itemType(at: sidecar) == nil else {
                throw PipelineError.generation("SQLite candidate is not self-contained; sidecar remains: \(sidecar.lastPathComponent)")
            }
        }

        let sharedMemory = URL(fileURLWithPath: url.path + "-shm")
        if let sidecarType = try SQLiteFileAccess.itemType(at: sharedMemory) {
            guard sidecarType == S_IFREG else {
                throw PipelineError.generation("SQLite candidate has an unsafe shared-memory sidecar: \(sharedMemory.path)")
            }
            try SQLiteFileAccess.requireClosed(at: url)
            try SQLiteFileAccess.requireClosed(at: sharedMemory)
            do {
                try FileManager.default.removeItem(at: sharedMemory)
            } catch {
                throw PipelineError.generation("Could not remove the closed orphaned SQLite shared-memory sidecar: \(error.localizedDescription)")
            }
        }

        for suffix in ["-wal", "-shm", "-journal"] {
            let sidecar = URL(fileURLWithPath: url.path + suffix)
            guard try SQLiteFileAccess.itemType(at: sidecar) == nil else {
                throw PipelineError.generation("SQLite candidate is not self-contained; sidecar remains: \(sidecar.lastPathComponent)")
            }
        }
    }

    static func verifyIntegrity(at url: URL) throws {
        try withDatabase(at: url, flags: SQLITE_OPEN_READONLY | SQLITE_OPEN_FULLMUTEX) { database in
            let results: [[String]]
            do {
                results = try rows("PRAGMA integrity_check", database: database)
            } catch {
                throw PipelineError.validation("SQLite integrity_check could not read the candidate: \(error)")
            }
            guard results == [["ok"]] else {
                let findings = results.flatMap { $0 }.joined(separator: "; ")
                throw PipelineError.validation("SQLite integrity_check failed: \(findings)")
            }
        }
    }

    private static func withDatabase<T>(
        at url: URL,
        flags: Int32,
        operation: (OpaquePointer) throws -> T
    ) throws -> T {
        var database: OpaquePointer?
        let status = sqlite3_open_v2(url.path, &database, flags, nil)
        guard status == SQLITE_OK, let database else {
            let detail = database.map { String(cString: sqlite3_errmsg($0)) } ?? String(cString: sqlite3_errstr(status))
            if let database { sqlite3_close_v2(database) }
            throw PipelineError.validation("SQLite open failed: \(detail)")
        }
        defer { sqlite3_close_v2(database) }
        return try operation(database)
    }

    private static func rows(_ sql: String, database: OpaquePointer) throws -> [[String]] {
        var statement: OpaquePointer?
        let prepareStatus = sqlite3_prepare_v2(database, sql, -1, &statement, nil)
        guard prepareStatus == SQLITE_OK, let statement else {
            throw PipelineError.validation("\(sql) could not be prepared: \(String(cString: sqlite3_errmsg(database)))")
        }
        defer { sqlite3_finalize(statement) }

        var result = [[String]]()
        while true {
            let stepStatus = sqlite3_step(statement)
            if stepStatus == SQLITE_DONE { return result }
            guard stepStatus == SQLITE_ROW else {
                throw PipelineError.validation("\(sql) failed: \(String(cString: sqlite3_errmsg(database)))")
            }
            result.append((0..<sqlite3_column_count(statement)).map { column in
                guard let value = sqlite3_column_text(statement, column) else { return "" }
                return String(cString: value)
            })
        }
    }
}

public enum CanonicalSnapshotBuilder {

    /// Attribute and relationship components defining stable record identity.
    /// Relationship components begin with `@` and resolve to the destination's
    /// own stable key. The map is part of snapshot schema version 2.
    public static let stableKeyComponents: [String: [String]] = [
        "StoredAbility": ["z_name"],
        "StoredBagItemInfo": ["@z_item"],
        "StoredBerryItemInfo": ["@z_item"],
        "StoredEvolution": [
            "z_game", "z_familyName", "@z_from", "@z_to", "z_methodName", "z_methodData",
            "z_conditionName", "z_conditionData", "z_conditionName2", "z_conditionData2"
        ],
        "StoredItem": ["z_game", "z_name"],
        "StoredLearnsetEntry": ["z_game", "z_learnsetType", "z_level", "@z_form", "@z_move", "@z_machine", "@z_fathers"],
        "StoredLocation": ["z_game", "z_region", "z_name"],
        "StoredLocationMap": ["@z_location", "z_areaName", "z_filename"],
        "StoredLocationPokemon": [
            "z_game", "@z_location", "@z_pokemon", "detail", "z_area", "z_captureMethod",
            "z_encounterCondition", "z_encounterRate", "z_encounterRateType", "z_levelLow", "z_levelHigh", "z_timeOfDay"
        ],
        "StoredMachine": ["z_game", "z_type", "z_number"],
        "StoredMove": ["z_game", "z_index", "z_name"],
        "StoredPokedexNumbers": ["@z_pokemon"],
        "StoredPokemon": ["z_game", "z_index"],
        "StoredPokemonForm": ["z_game", "z_index", "z_formIndex", "z_name"],
        "StoredStats": ["@zUNUSED_form", "@zUNUSED_form_evYield"]
    ]

    /// Generated lookup-cache attributes excluded from semantic comparison.
    ///
    /// `StoredAbility.z_index` is assigned while loading the ability dictionary.
    /// The three form index attributes mirror the corresponding ability
    /// relationships solely to support indexed fetch predicates. A change in
    /// the numeric assignment changes all four values together without changing
    /// which ability a form references. The relationships remain canonical and
    /// are compared by the ability's stable name.
    public static let excludedDerivedAttributes: [String: Set<String>] = [
        "StoredAbility": ["z_index"],
        "StoredPokemonForm": [
            "i_hiddenAbilityIndex",
            "i_primaryAbilityIndex",
            "i_secondaryAbilityIndex"
        ]
    ]

    public static func build(databaseURL: URL) throws -> (CanonicalDatabaseSnapshot, [ValidationIssue]) {
        guard FileManager.default.fileExists(atPath: databaseURL.path) else {
            throw PipelineError.missingPrerequisite("Database is missing: \(databaseURL.path)")
        }
        try SQLiteDatabase.verifyIntegrity(at: databaseURL)
        guard let modelURL = Bundle.pokedexCore.url(forResource: "Pokedex", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            throw PipelineError.missingPrerequisite("Compiled Pokedex Core Data model is unavailable")
        }

        let metadata: [String: Any]
        do {
            metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(
                ofType: NSSQLiteStoreType,
                at: databaseURL,
                options: [NSReadOnlyPersistentStoreOption: true]
            )
        } catch {
            throw PipelineError.validation("Could not read Core Data store metadata: \(error.localizedDescription)")
        }
        guard model.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) else {
            throw PipelineError.validation("Database schema is incompatible with the authoritative compiled catalog model")
        }

        let container = NSPersistentContainer(name: "Pokedex", managedObjectModel: model)
        let description = NSPersistentStoreDescription(url: databaseURL)
        description.type = NSSQLiteStoreType
        description.isReadOnly = true
        description.shouldAddStoreAsynchronously = false
        container.persistentStoreDescriptions = [description]
        var loadError: Error?
        container.loadPersistentStores { _, error in loadError = error }
        if let loadError {
            throw PipelineError.validation("Could not open candidate database read-only: \(loadError.localizedDescription)")
        }

        defer {
            for store in container.persistentStoreCoordinator.persistentStores {
                try? container.persistentStoreCoordinator.remove(store)
            }
        }

        let context = container.viewContext
        var issues = [ValidationIssue]()
        var entities = [CanonicalDatabaseSnapshot.Entity]()
        var keyCache = [NSManagedObjectID: String]()

        for entity in model.entities.compactMap({ $0.name }).sorted() {
            guard stableKeyComponents[entity] != nil else {
                issues.append(.init(
                    code: "missing_stable_key_strategy",
                    entity: entity,
                    key: "",
                    message: "Snapshot schema has no explicit stable-key strategy"
                ))
                continue
            }
            let request = NSFetchRequest<NSManagedObject>(entityName: entity)
            request.returnsObjectsAsFaults = false
            let objects: [NSManagedObject]
            do {
                objects = try context.fetch(request)
            } catch {
                throw PipelineError.validation("Failed to fetch \(entity): \(error.localizedDescription)")
            }

            var records = [CanonicalDatabaseSnapshot.Record]()
            for object in objects {
                let key = stableKey(for: object, cache: &keyCache)
                let excludedAttributes = excludedDerivedAttributes[entity, default: []]
                let attributes = object.entity.attributesByName.keys
                    .filter { !excludedAttributes.contains($0) }
                    .sorted()
                    .map {
                    CanonicalDatabaseSnapshot.Field(name: $0, value: scalar(object.value(forKey: $0)))
                }
                let relationships = object.entity.relationshipsByName.keys
                    .filter { !$0.hasPrefix("zUNUSED_") }
                    .sorted()
                    .map { relationshipName in
                        CanonicalDatabaseSnapshot.Relationship(
                            name: relationshipName,
                            targetKeys: relationshipKeys(
                                object.value(forKey: relationshipName),
                                cache: &keyCache
                            )
                        )
                    }
                records.append(.init(key: key, attributes: attributes, relationships: relationships))
            }
            records.sort { lhs, rhs in
                if lhs.key != rhs.key { return lhs.key < rhs.key }
                return String(describing: lhs) < String(describing: rhs)
            }

            issues.append(contentsOf: duplicateStableKeyIssues(entity: entity, records: records))
            entities.append(.init(name: entity, records: records))
        }

        issues.append(contentsOf: datasetCoverageIssues(entities: entities))
        issues.append(contentsOf: validateRelationships(context: context, model: model, keyCache: &keyCache))
        issues.append(contentsOf: validateGameIndices(context: context, model: model, keyCache: &keyCache))

        let snapshot = CanonicalDatabaseSnapshot(
            modelFingerprint: try modelFingerprint(model),
            datasets: Game.allDatasets.sorted(by: { $0.databaseIndex < $1.databaseIndex }).map(\.rawValue),
            entities: entities.sorted(by: { $0.name < $1.name })
        )
        return (snapshot, issues.sorted())
    }

    private static func stableKey(
        for object: NSManagedObject,
        cache: inout [NSManagedObjectID: String]
    ) -> String {
        if let cached = cache[object.objectID] { return cached }
        let entity = object.entity.name ?? "Unknown"
        let components = stableKeyComponents[entity, default: object.entity.attributesByName.keys.sorted()]
        let values = components.map { component -> String in
            if component.hasPrefix("@") {
                return relationshipKeys(object.value(forKey: String(component.dropFirst())), cache: &cache).joined(separator: ",")
            }
            return scalar(object.value(forKey: component))
        }
        let encoded = values.map { Data($0.utf8).base64EncodedString() }.joined(separator: ".")
        let key = entity + ":" + encoded
        cache[object.objectID] = key
        return key
    }

    private static func relationshipKeys(
        _ value: Any?,
        cache: inout [NSManagedObjectID: String]
    ) -> [String] {
        if let object = value as? NSManagedObject {
            return [stableKey(for: object, cache: &cache)]
        }
        if let set = value as? Set<NSManagedObject> {
            return set.map { stableKey(for: $0, cache: &cache) }.sorted()
        }
        if let set = value as? NSSet {
            return set.compactMap { $0 as? NSManagedObject }.map { stableKey(for: $0, cache: &cache) }.sorted()
        }
        if let ordered = value as? NSOrderedSet {
            return ordered.compactMap { $0 as? NSManagedObject }.map { stableKey(for: $0, cache: &cache) }.sorted()
        }
        return []
    }

    private static func scalar(_ value: Any?) -> String {
        guard let value else { return "null" }
        if let string = value as? String { return "string:" + string }
        if let number = value as? NSNumber { return "number:" + number.stringValue }
        if let date = value as? Date { return "date:" + String(format: "%.6f", date.timeIntervalSinceReferenceDate) }
        if let data = value as? Data { return "data:" + data.base64EncodedString() }
        if let url = value as? URL { return "url:" + url.absoluteString }
        return "value:" + String(describing: value)
    }

    private static func modelFingerprint(_ model: NSManagedObjectModel) throws -> String {
        struct Schema: Codable {
            struct Entity: Codable {
                let name: String
                let attributes: [String]
                let relationships: [String]
            }
            let entities: [Entity]
        }
        let schema = Schema(entities: model.entities.compactMap { entity in
            guard let name = entity.name else { return nil }
            let attributes = entity.attributesByName.values.map {
                "\($0.name)|\($0.attributeType.rawValue)|\($0.isOptional)|\($0.defaultValue.map(String.init(describing:)) ?? "null")"
            }.sorted()
            let relationships = entity.relationshipsByName.values.map {
                "\($0.name)|\($0.destinationEntity?.name ?? "")|\($0.isToMany)|\($0.isOptional)|\($0.deleteRule.rawValue)|\($0.inverseRelationship?.name ?? "")"
            }.sorted()
            return .init(name: name, attributes: attributes, relationships: relationships)
        }.sorted(by: { $0.name < $1.name }))
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(schema)
        return SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    /// Detects duplicate identifiers according to the current snapshot schema.
    public static func duplicateStableKeyIssues(
        entity: String,
        records: [CanonicalDatabaseSnapshot.Record]
    ) -> [ValidationIssue] {
        Dictionary(grouping: records, by: \.key).values.compactMap { group in
            guard group.count > 1 else { return nil }
            return .init(
                severity: .warning,
                code: "duplicate_stable_key",
                entity: entity,
                key: group[0].key,
                message: "Found \(group.count) records with the same stable key"
            )
        }.sorted()
    }

    /// Validates every released dataset and National against the compiled catalog.
    public static func datasetCoverageIssues(
        entities: [CanonicalDatabaseSnapshot.Entity]
    ) -> [ValidationIssue] {
        let required = Set(Game.allDatasets.map(\.rawValue))
        let entityNames = ["StoredItem", "StoredMove", "StoredPokemon", "StoredPokemonForm"]
        return entityNames.flatMap { entityName -> [ValidationIssue] in
            guard let entity = entities.first(where: { $0.name == entityName }) else {
                return [.init(code: "missing_entity", entity: entityName, key: "", message: "Required entity is absent")]
            }
            let games = Set(entity.records.compactMap { record in
                record.attributes.first(where: { $0.name == "z_game" })?.value.replacingOccurrences(of: "string:", with: "")
            })
            return required.subtracting(games).sorted().map {
                .init(code: "missing_dataset", entity: entityName, key: $0, message: "Required generated dataset is absent")
            }
        }
    }

    private static func validateRelationships(
        context: NSManagedObjectContext,
        model: NSManagedObjectModel,
        keyCache: inout [NSManagedObjectID: String]
    ) -> [ValidationIssue] {
        let required: [String: [String]] = [
            "StoredBagItemInfo": ["z_item"],
            "StoredBerryItemInfo": ["z_item"],
            "StoredEvolution": ["z_from", "z_to"],
            "StoredLearnsetEntry": ["z_form", "z_move"],
            "StoredLocationMap": ["z_location"],
            "StoredLocationPokemon": ["z_location", "z_pokemon"],
            "StoredMachine": ["z_move"],
            "StoredPokedexNumbers": ["z_pokemon"],
            "StoredPokemon": ["z_forms"],
            // Ability relationships are optional in the model and runtime API.
            "StoredPokemonForm": ["z_baseStats", "z_evYield", "z_pokemon"]
        ]
        var issues = [ValidationIssue]()
        for (entityName, relationships) in required.sorted(by: { $0.key < $1.key }) {
            guard model.entitiesByName[entityName] != nil else { continue }
            let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
            guard let objects = try? context.fetch(request) else { continue }
            for object in objects {
                let key = stableKey(for: object, cache: &keyCache)
                for relationship in relationships {
                    let keys = relationshipKeys(object.value(forKey: relationship), cache: &keyCache)
                    if keys.isEmpty {
                        issues.append(.init(
                            code: "broken_relationship",
                            entity: entityName,
                            key: key,
                            message: "Required relationship \(relationship) is empty"
                        ))
                    }
                }
            }
        }
        return issues
    }

    private static func validateGameIndices(
        context: NSManagedObjectContext,
        model: NSManagedObjectModel,
        keyCache: inout [NSManagedObjectID: String]
    ) -> [ValidationIssue] {
        var issues = [ValidationIssue]()
        for entity in model.entities where entity.attributesByName["z_game"] != nil && entity.attributesByName["i_gameIndex"] != nil {
            guard let entityName = entity.name else { continue }
            let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
            guard let objects = try? context.fetch(request) else { continue }
            for object in objects {
                guard let rawGame = object.value(forKey: "z_game") as? String,
                      let game = Game(rawValue: rawGame),
                      let index = object.value(forKey: "i_gameIndex") as? NSNumber else {
                    issues.append(.init(
                        code: "invalid_game_mapping",
                        entity: entityName,
                        key: stableKey(for: object, cache: &keyCache),
                        message: "Game raw value or database index is invalid"
                    ))
                    continue
                }
                if index.intValue != game.databaseIndex {
                    issues.append(.init(
                        code: "invalid_game_mapping",
                        entity: entityName,
                        key: stableKey(for: object, cache: &keyCache),
                        message: "Expected database index \(game.databaseIndex), found \(index.intValue)"
                    ))
                }
            }
        }
        return issues
    }
}
