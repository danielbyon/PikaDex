//
//  PersistenceBootstrap.swift
//  PokedexCore
//
//  Copyright © 2026 Daniel Byon. All rights reserved.
//

import CoreData
import Foundation

/// A fully loaded pair of data stores used by PikaDex features.
///
/// Instances are created only after both required persistent stores have loaded
/// successfully. Callers can therefore pass either data store to feature code
/// without exposing a context that is still loading.
public final class PersistenceStores {

    /// The read-only generated Pokédex catalog.
    public let pokedex: DataStore

    /// The writable store containing user-owned data.
    public let userData: DataStore

    internal let pokedexContainer: NSPersistentContainer
    internal let userDataContainer: NSPersistentContainer

    internal init(
        pokedexContainer: NSPersistentContainer,
        userDataContainer: NSPersistentContainer
    ) {
        self.pokedexContainer = pokedexContainer
        self.userDataContainer = userDataContainer
        self.pokedex = DataStore(container: pokedexContainer)
        self.userData = DataStore(container: userDataContainer)
    }
}

/// A structured failure produced while preparing Core Data for use.
///
/// Public descriptions intentionally omit filesystem paths. Internal tests and
/// diagnostics can inspect the retained URLs without placing them in ordinary
/// logs or release-facing messages.
public struct PersistenceBootstrapError: Error, LocalizedError, CustomStringConvertible, CustomDebugStringConvertible {

    /// The bootstrap operation that failed.
    public enum Stage: String {
        case locatingModel
        case loadingModel
        case locatingStore
        case inspectingStore
        case preparingStore
        case loadingStore
        case validatingStore
        case testConfiguration
    }

    /// The safe recovery guidance associated with a failure.
    public enum RecoveryContext: String {
        case verifyBundledResources
        case verifyStoreConfiguration
        case preserveStoreForDiagnosis
        case injectTestStore
    }

    /// A non-sensitive snapshot of the store being prepared.
    public struct StoreDescription {
        public let name: String
        public let type: String
        public let isReadOnly: Bool
        public let shouldMigrateAutomatically: Bool
        public let shouldInferMappingAutomatically: Bool
        public let shouldLoadAsynchronously: Bool
    }

    public let stage: Stage
    public let modelName: String
    public let resourceName: String?
    public let storeDescription: StoreDescription?
    public let recoveryContext: RecoveryContext
    public let underlyingError: Error?

    internal let modelURL: URL?
    internal let resourceURL: URL?

    /// A path-free message suitable for release logs and termination messages.
    public var errorDescription: String? {
        switch stage {
        case .locatingModel, .loadingModel:
            return "PikaDex could not load its data model."
        case .locatingStore, .inspectingStore, .preparingStore:
            return "PikaDex could not prepare its data store."
        case .loadingStore:
            return "PikaDex could not open its data store."
        case .validatingStore:
            return "PikaDex opened its catalog but could not verify its contents."
        case .testConfiguration:
            return "A test data store must be injected before this dependency is used."
        }
    }

    public var description: String { errorDescription ?? "PikaDex persistence failed." }

    public var debugDescription: String { description }

    internal init(
        stage: Stage,
        modelName: String,
        resourceName: String? = nil,
        modelURL: URL? = nil,
        resourceURL: URL? = nil,
        storeDescription: StoreDescription? = nil,
        recoveryContext: RecoveryContext,
        underlyingError: Error? = nil
    ) {
        self.stage = stage
        self.modelName = modelName
        self.resourceName = resourceName
        self.modelURL = modelURL
        self.resourceURL = resourceURL
        self.storeDescription = storeDescription
        self.recoveryContext = recoveryContext
        self.underlyingError = underlyingError
    }
}

/// Owns deterministic construction of the PikaDex Core Data stores.
///
/// `production()` is the only cached factory. Preview, test, and bundled-catalog
/// integration factories are intentionally uncached so their stores cannot
/// leak state between callers.
public enum PersistenceBootstrap {

    internal struct ResourceResolver {
        let modelURL: (_ modelName: String) -> URL?
        let resourceURL: (_ resourceName: String, _ extensionName: String) -> URL?

        static func bundle(_ bundle: Bundle) -> ResourceResolver {
            ResourceResolver(
                modelURL: { bundle.url(forResource: $0, withExtension: "momd") },
                resourceURL: { bundle.url(forResource: $0, withExtension: $1) }
            )
        }
    }

    internal enum StoreLocation {
        case bundledCatalog
        case sqlite(URL)
        case inMemory
    }

    internal struct Configuration {
        let resolver: ResourceResolver
        let pokedexStore: StoreLocation
        let userDataStore: StoreLocation
        let validatesBundledCatalog: Bool
    }

    internal final class Cache {
        private let lock = NSLock()
        private let loader: () throws -> PersistenceStores
        private var result: Result<PersistenceStores, Error>?

        init(loader: @escaping () throws -> PersistenceStores) {
            self.loader = loader
        }

        func load() throws -> PersistenceStores {
            lock.lock()
            defer { lock.unlock() }

            if let result {
                return try result.get()
            }

            let result = Result(catching: loader)
            self.result = result
            return try result.get()
        }
    }

    private static let productionCacheLock = NSLock()
    private static var productionCache = makeProductionCache()

    /// Loads and caches the production catalog and writable user-data store.
    ///
    /// The call returns only after both stores are ready. A failed attempt is
    /// cached as well, preventing implicit retry or destructive recovery.
    public static func production() throws -> PersistenceStores {
        productionCacheLock.lock()
        let cache = productionCache
        productionCacheLock.unlock()
        return try cache.load()
    }

    /// Creates uncached preview stores.
    ///
    /// Previews read the real catalog in read-only mode while all user-data
    /// writes remain in memory.
    public static func preview() throws -> PersistenceStores {
        try make(configuration: bundledCatalogConfiguration(userDataStore: .inMemory))
    }

    /// Creates two isolated in-memory stores for tests.
    ///
    /// Each invocation returns independent contexts and never opens the bundled
    /// production database.
    public static func makeInMemoryForTesting() throws -> PersistenceStores {
        try make(configuration: Configuration(
            resolver: .bundle(.pokedexCore),
            pokedexStore: .inMemory,
            userDataStore: .inMemory,
            validatesBundledCatalog: false
        ))
    }

    /// Creates two isolated SQLite stores inside a caller-owned test directory.
    ///
    /// The caller is responsible for deleting the directory after the test.
    public static func makeTemporaryForTesting(directoryURL: URL) throws -> PersistenceStores {
        try make(configuration: Configuration(
            resolver: .bundle(.pokedexCore),
            pokedexStore: .sqlite(directoryURL.appendingPathComponent("Pokedex.sqlite")),
            userDataStore: .sqlite(directoryURL.appendingPathComponent("UserData.sqlite")),
            validatesBundledCatalog: false
        ))
    }

    /// Creates an uncached read-only catalog for integration tests.
    ///
    /// User data remains in memory, and this factory does not read or mutate the
    /// process-wide production cache.
    internal static func makeBundledCatalogForTesting() throws -> PersistenceStores {
        try make(configuration: bundledCatalogConfiguration(userDataStore: .inMemory))
    }

    internal static func make(configuration: Configuration) throws -> PersistenceStores {
        let pokedexContainer = try makeContainer(
            modelName: "Pokedex",
            location: configuration.pokedexStore,
            resolver: configuration.resolver,
            validatesCatalog: configuration.validatesBundledCatalog
        )
        let userDataContainer = try makeContainer(
            modelName: "UserData",
            location: configuration.userDataStore,
            resolver: configuration.resolver,
            validatesCatalog: false
        )
        return PersistenceStores(
            pokedexContainer: pokedexContainer,
            userDataContainer: userDataContainer
        )
    }

    /// Replaces the production cache for deterministic singleton tests.
    ///
    /// This hook is internal and does not provide a production retry or recovery
    /// API. Tests must restore the default cache in teardown.
    internal static func replaceProductionCacheForTesting(_ cache: Cache) {
        productionCacheLock.lock()
        productionCache = cache
        productionCacheLock.unlock()
    }

    internal static func restoreProductionCacheForTesting() {
        replaceProductionCacheForTesting(makeProductionCache())
    }

    private static func makeProductionCache() -> Cache {
        Cache {
            try make(configuration: bundledCatalogConfiguration(
                userDataStore: .sqlite(
                    NSPersistentContainer.defaultDirectoryURL()
                        .appendingPathComponent("UserData.sqlite")
                )
            ))
        }
    }

    private static func bundledCatalogConfiguration(userDataStore: StoreLocation) -> Configuration {
        Configuration(
            resolver: .bundle(.pokedexCore),
            pokedexStore: .bundledCatalog,
            userDataStore: userDataStore,
            validatesBundledCatalog: true
        )
    }

    private static func makeContainer(
        modelName: String,
        location: StoreLocation,
        resolver: ResourceResolver,
        validatesCatalog: Bool
    ) throws -> NSPersistentContainer {
        guard let modelURL = resolver.modelURL(modelName) else {
            throw PersistenceBootstrapError(
                stage: .locatingModel,
                modelName: modelName,
                resourceName: "\(modelName).momd",
                recoveryContext: .verifyBundledResources
            )
        }
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            throw PersistenceBootstrapError(
                stage: .loadingModel,
                modelName: modelName,
                resourceName: "\(modelName).momd",
                modelURL: modelURL,
                recoveryContext: .verifyBundledResources
            )
        }

        let description = try makeStoreDescription(
            modelName: modelName,
            location: location,
            resolver: resolver,
            modelURL: modelURL
        )
        let snapshot = snapshot(of: description, name: modelName)
        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]

        var loadedDescriptionCount = 0
        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadedDescriptionCount += 1
            loadError = error
        }

        if let loadError {
            throw PersistenceBootstrapError(
                stage: .loadingStore,
                modelName: modelName,
                modelURL: modelURL,
                resourceURL: description.url,
                storeDescription: snapshot,
                recoveryContext: .preserveStoreForDiagnosis,
                underlyingError: loadError
            )
        }
        guard loadedDescriptionCount == 1,
              container.persistentStoreCoordinator.persistentStores.count == 1 else {
            throw PersistenceBootstrapError(
                stage: .loadingStore,
                modelName: modelName,
                modelURL: modelURL,
                resourceURL: description.url,
                storeDescription: snapshot,
                recoveryContext: .preserveStoreForDiagnosis
            )
        }

        configureViewContext(container.viewContext)

        if validatesCatalog {
            try validateBundledCatalog(
                container.viewContext,
                modelURL: modelURL,
                description: snapshot,
                storeURL: description.url
            )
        }
        return container
    }

    private static func makeStoreDescription(
        modelName: String,
        location: StoreLocation,
        resolver: ResourceResolver,
        modelURL: URL
    ) throws -> NSPersistentStoreDescription {
        let description: NSPersistentStoreDescription

        switch location {
        case .bundledCatalog:
            guard let databaseURL = resolver.resourceURL("Pokedex", "sqlite") else {
                throw PersistenceBootstrapError(
                    stage: .locatingStore,
                    modelName: modelName,
                    resourceName: "Pokedex.sqlite",
                    modelURL: modelURL,
                    recoveryContext: .verifyBundledResources
                )
            }
            try inspectMainDatabase(databaseURL, modelName: modelName, modelURL: modelURL)
            try inspectSidecarIfPresent(
                resolver.resourceURL("Pokedex", "sqlite-wal"),
                expectedURL: URL(fileURLWithPath: databaseURL.path + "-wal"),
                modelName: modelName,
                modelURL: modelURL
            )
            try inspectSidecarIfPresent(
                resolver.resourceURL("Pokedex", "sqlite-shm"),
                expectedURL: URL(fileURLWithPath: databaseURL.path + "-shm"),
                modelName: modelName,
                modelURL: modelURL
            )

            description = NSPersistentStoreDescription(url: databaseURL)
            description.type = NSSQLiteStoreType
            description.isReadOnly = true
            description.shouldMigrateStoreAutomatically = false
            description.shouldInferMappingModelAutomatically = false

        case .sqlite(let storeURL):
            do {
                try FileManager.default.createDirectory(
                    at: storeURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
            } catch {
                throw PersistenceBootstrapError(
                    stage: .preparingStore,
                    modelName: modelName,
                    modelURL: modelURL,
                    resourceURL: storeURL,
                    recoveryContext: .verifyStoreConfiguration,
                    underlyingError: error
                )
            }
            description = NSPersistentStoreDescription(url: storeURL)
            description.type = NSSQLiteStoreType
            description.isReadOnly = false
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true

        case .inMemory:
            description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            description.isReadOnly = false
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
        }

        description.shouldAddStoreAsynchronously = false
        return description
    }

    private static func inspectMainDatabase(
        _ url: URL,
        modelName: String,
        modelURL: URL
    ) throws {
        do {
            let values = try url.resourceValues(forKeys: [.isRegularFileKey, .isReadableKey])
            guard values.isRegularFile == true, values.isReadable == true else {
                throw CocoaError(.fileReadNoPermission)
            }
        } catch {
            throw PersistenceBootstrapError(
                stage: .inspectingStore,
                modelName: modelName,
                resourceName: "Pokedex.sqlite",
                modelURL: modelURL,
                resourceURL: url,
                recoveryContext: .verifyBundledResources,
                underlyingError: error
            )
        }
    }

    private static func inspectSidecarIfPresent(
        _ url: URL?,
        expectedURL: URL,
        modelName: String,
        modelURL: URL
    ) throws {
        guard let url else { return }

        do {
            let values = try url.resourceValues(forKeys: [.isRegularFileKey, .isReadableKey])
            guard values.isRegularFile == true,
                  values.isReadable == true,
                  url.standardizedFileURL == expectedURL.standardizedFileURL else {
                throw CocoaError(.fileReadCorruptFile)
            }
        } catch {
            throw PersistenceBootstrapError(
                stage: .inspectingStore,
                modelName: modelName,
                resourceName: url.lastPathComponent,
                modelURL: modelURL,
                resourceURL: url,
                recoveryContext: .verifyBundledResources,
                underlyingError: error
            )
        }
    }

    private static func configureViewContext(_ context: NSManagedObjectContext) {
        // These assignments preserve the effective settings of the previous
        // NSPersistentContainer implementation while making the contract clear.
        context.mergePolicy = NSErrorMergePolicy
        context.automaticallyMergesChangesFromParent = false
        context.undoManager = nil
        context.transactionAuthor = nil
        context.retainsRegisteredObjects = false
    }

    private static func validateBundledCatalog(
        _ context: NSManagedObjectContext,
        modelURL: URL,
        description: PersistenceBootstrapError.StoreDescription,
        storeURL: URL?
    ) throws {
        var validationError: Error?

        context.performAndWait {
            do {
                let nationalRequest = NSFetchRequest<NSManagedObject>(entityName: "StoredPokemon")
                nationalRequest.predicate = NSPredicate(format: "z_game == %@", Game.national.rawValue)
                nationalRequest.sortDescriptors = [NSSortDescriptor(key: "z_index", ascending: true)]
                nationalRequest.fetchLimit = 1

                let releasedRequest = NSFetchRequest<NSManagedObject>(entityName: "StoredPokemon")
                releasedRequest.predicate = NSPredicate(format: "z_game == %@", Game.scarlet.rawValue)
                releasedRequest.fetchLimit = 1

                guard let firstNationalPokemon = try context.fetch(nationalRequest).first,
                      firstNationalPokemon.value(forKey: "z_name") as? String == "Bulbasaur",
                      try context.count(for: releasedRequest) > 0 else {
                    throw CocoaError(.persistentStoreIncompatibleSchema)
                }
            } catch {
                validationError = error
            }
        }

        if let validationError {
            throw PersistenceBootstrapError(
                stage: .validatingStore,
                modelName: "Pokedex",
                modelURL: modelURL,
                resourceURL: storeURL,
                storeDescription: description,
                recoveryContext: .preserveStoreForDiagnosis,
                underlyingError: validationError
            )
        }
    }

    private static func snapshot(
        of description: NSPersistentStoreDescription,
        name: String
    ) -> PersistenceBootstrapError.StoreDescription {
        PersistenceBootstrapError.StoreDescription(
            name: name,
            type: description.type,
            isReadOnly: description.isReadOnly,
            shouldMigrateAutomatically: description.shouldMigrateStoreAutomatically,
            shouldInferMappingAutomatically: description.shouldInferMappingModelAutomatically,
            shouldLoadAsynchronously: description.shouldAddStoreAsynchronously
        )
    }
}
