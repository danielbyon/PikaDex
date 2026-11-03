//
//  PersistenceBootstrapTests.swift
//  PokedexCoreTests
//
//  Copyright © 2026 Daniel Byon. All rights reserved.
//

import CoreData
import XCTest

@testable import PokedexCore

final class PersistenceBootstrapTests: XCTestCase {

    private struct TestError: Error { }

    override func tearDown() {
        PersistenceBootstrap.restoreProductionCacheForTesting()
        super.tearDown()
    }

    func testInMemoryStoresAreReadyAndPreserveContextConfiguration() throws {
        let stores = try PersistenceBootstrap.makeInMemoryForTesting()

        for container in [stores.pokedexContainer, stores.userDataContainer] {
            XCTAssertEqual(container.persistentStoreCoordinator.persistentStores.count, 1)
            XCTAssertEqual(container.persistentStoreDescriptions.count, 1)
            XCTAssertEqual(container.persistentStoreDescriptions.first?.type, NSInMemoryStoreType)

            let context = container.viewContext
            XCTAssertEqual(context.concurrencyType, .mainQueueConcurrencyType)
            XCTAssertEqual(
                (context.mergePolicy as? NSMergePolicy)?.mergeType,
                .errorMergePolicyType
            )
            XCTAssertFalse(context.automaticallyMergesChangesFromParent)
            XCTAssertNil(context.undoManager)
            XCTAssertNil(context.transactionAuthor)
            XCTAssertFalse(context.retainsRegisteredObjects)
        }
    }

    func testInMemoryStoresAreIsolatedBetweenBootstraps() throws {
        let first = try PersistenceBootstrap.makeInMemoryForTesting()
        let second = try PersistenceBootstrap.makeInMemoryForTesting()
        let caughtPokemon = try JSONDecoder().decode(
            CaughtPokemon.self,
            from: Data(#"{"pokemonName":"Bulbasaur","formName":"Bulbasaur","index":1,"game":"national"}"#.utf8)
        )

        try first.userData.save(caughtPokemon)

        XCTAssertEqual(
            try first.userData.fetch(CaughtPokemon.self, filter: .init(game: .national)).count,
            1
        )
        XCTAssertTrue(
            try second.userData.fetch(CaughtPokemon.self, filter: .init(game: .national)).isEmpty
        )
    }

    func testTemporarySQLiteStoresUseCallerOwnedDirectory() throws {
        let directory = try makeTemporaryDirectory()
        let stores = try PersistenceBootstrap.makeTemporaryForTesting(directoryURL: directory)

        XCTAssertEqual(
            stores.pokedexContainer.persistentStoreDescriptions.first?.url,
            directory.appendingPathComponent("Pokedex.sqlite")
        )
        XCTAssertEqual(
            stores.userDataContainer.persistentStoreDescriptions.first?.url,
            directory.appendingPathComponent("UserData.sqlite")
        )
        XCTAssertTrue(FileManager.default.fileExists(atPath: directory.appendingPathComponent("Pokedex.sqlite").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: directory.appendingPathComponent("UserData.sqlite").path))
    }

    func testMissingModelProducesStructuredError() {
        let configuration = PersistenceBootstrap.Configuration(
            resolver: .init(modelURL: { _ in nil }, resourceURL: { _, _ in nil }),
            pokedexStore: .inMemory,
            userDataStore: .inMemory,
            validatesBundledCatalog: false
        )

        assertBootstrapError(try PersistenceBootstrap.make(configuration: configuration)) {
            XCTAssertEqual($0.stage, .locatingModel)
            XCTAssertEqual($0.modelName, "Pokedex")
            XCTAssertEqual($0.recoveryContext, .verifyBundledResources)
            XCTAssertNil($0.underlyingError)
        }
    }

    func testInvalidModelProducesStructuredError() throws {
        let directory = try makeTemporaryDirectory()
        let invalidModelURL = directory.appendingPathComponent("Invalid.momd", isDirectory: true)
        try FileManager.default.createDirectory(at: invalidModelURL, withIntermediateDirectories: true)
        let configuration = PersistenceBootstrap.Configuration(
            resolver: .init(modelURL: { _ in invalidModelURL }, resourceURL: { _, _ in nil }),
            pokedexStore: .inMemory,
            userDataStore: .inMemory,
            validatesBundledCatalog: false
        )

        assertBootstrapError(try PersistenceBootstrap.make(configuration: configuration)) {
            XCTAssertEqual($0.stage, .loadingModel)
            XCTAssertEqual($0.modelURL, invalidModelURL)
        }
    }

    func testMissingMainDatabaseProducesStructuredError() {
        let bundleResolver = PersistenceBootstrap.ResourceResolver.bundle(.pokedexCore)
        let configuration = PersistenceBootstrap.Configuration(
            resolver: .init(
                modelURL: bundleResolver.modelURL,
                resourceURL: { _, _ in nil }
            ),
            pokedexStore: .bundledCatalog,
            userDataStore: .inMemory,
            validatesBundledCatalog: true
        )

        assertBootstrapError(try PersistenceBootstrap.make(configuration: configuration)) {
            XCTAssertEqual($0.stage, .locatingStore)
            XCTAssertEqual($0.resourceName, "Pokedex.sqlite")
        }
    }

    func testMissingSidecarsDeferToStoreLoadWhenNoWalDependencyIsProven() throws {
        let directory = try makeTemporaryDirectory()
        let resolver = PersistenceBootstrap.ResourceResolver.bundle(.pokedexCore)
        guard let bundledDatabaseURL = resolver.resourceURL("Pokedex", "sqlite") else {
            return XCTFail("The test bundle must contain Pokedex.sqlite")
        }
        let linkedDatabaseURL = directory.appendingPathComponent("Pokedex.sqlite")
        try FileManager.default.linkItem(at: bundledDatabaseURL, to: linkedDatabaseURL)

        let configuration = PersistenceBootstrap.Configuration(
            resolver: .init(
                modelURL: resolver.modelURL,
                resourceURL: { _, extensionName in
                    extensionName == "sqlite" ? linkedDatabaseURL : nil
                }
            ),
            pokedexStore: .bundledCatalog,
            userDataStore: .inMemory,
            validatesBundledCatalog: true
        )
        assertBootstrapError(try PersistenceBootstrap.make(configuration: configuration)) {
            // Core Data cannot open this WAL-mode store without the sidecars,
            // even though the WAL has no pending frames. Bootstrap discovery
            // does not misreport that platform limitation as proof of missing
            // uncheckpointed data.
            XCTAssertEqual($0.stage, .loadingStore)
            XCTAssertEqual($0.resourceURL, linkedDatabaseURL)
            XCTAssertNotNil($0.underlyingError)
        }
    }

    func testUncachedBundledCatalogOpensReadOnlyAndReturnsRepresentativeData() throws {
        let stores = try PersistenceBootstrap.makeBundledCatalogForTesting()
        let description = try XCTUnwrap(stores.pokedexContainer.persistentStoreDescriptions.first)

        XCTAssertTrue(description.isReadOnly)
        XCTAssertFalse(description.shouldMigrateStoreAutomatically)
        XCTAssertFalse(description.shouldInferMappingModelAutomatically)
        XCTAssertEqual(
            try stores.pokedex.fetch(Pokemon.self, filter: .default(for: .national)).first?.name,
            "Bulbasaur"
        )
        XCTAssertFalse(
            try stores.pokedex.fetch(Pokemon.self, filter: .default(for: .scarlet)).isEmpty
        )
    }

    func testInvalidPresentSidecarProducesStructuredError() throws {
        let directory = try makeTemporaryDirectory()
        let resolver = PersistenceBootstrap.ResourceResolver.bundle(.pokedexCore)
        let configuration = PersistenceBootstrap.Configuration(
            resolver: .init(
                modelURL: resolver.modelURL,
                resourceURL: { name, extensionName in
                    if extensionName == "sqlite-wal" { return directory }
                    return resolver.resourceURL(name, extensionName)
                }
            ),
            pokedexStore: .bundledCatalog,
            userDataStore: .inMemory,
            validatesBundledCatalog: true
        )

        assertBootstrapError(try PersistenceBootstrap.make(configuration: configuration)) {
            XCTAssertEqual($0.stage, .inspectingStore)
            XCTAssertEqual($0.recoveryContext, .verifyBundledResources)
            XCTAssertNotNil($0.underlyingError)
        }
    }

    func testCorruptSQLitePropagatesPersistentStoreLoadFailure() throws {
        let directory = try makeTemporaryDirectory()
        let corruptStoreURL = directory.appendingPathComponent("Corrupt.sqlite")
        try Data("not a sqlite database".utf8).write(to: corruptStoreURL)
        let resolver = PersistenceBootstrap.ResourceResolver.bundle(.pokedexCore)
        let configuration = PersistenceBootstrap.Configuration(
            resolver: resolver,
            pokedexStore: .sqlite(corruptStoreURL),
            userDataStore: .inMemory,
            validatesBundledCatalog: false
        )

        assertBootstrapError(try PersistenceBootstrap.make(configuration: configuration)) {
            XCTAssertEqual($0.stage, .loadingStore)
            XCTAssertEqual($0.resourceURL, corruptStoreURL)
            XCTAssertNotNil($0.storeDescription)
            XCTAssertNotNil($0.underlyingError)
            XCTAssertFalse($0.localizedDescription.contains(directory.path))
        }
    }

    func testUnwritableStoreDirectoryProducesPreparationError() throws {
        let directory = try makeTemporaryDirectory()
        let fileURL = directory.appendingPathComponent("NotADirectory")
        try Data().write(to: fileURL)
        let storeURL = fileURL.appendingPathComponent("Pokedex.sqlite")
        let resolver = PersistenceBootstrap.ResourceResolver.bundle(.pokedexCore)
        let configuration = PersistenceBootstrap.Configuration(
            resolver: resolver,
            pokedexStore: .sqlite(storeURL),
            userDataStore: .inMemory,
            validatesBundledCatalog: false
        )

        assertBootstrapError(try PersistenceBootstrap.make(configuration: configuration)) {
            XCTAssertEqual($0.stage, .preparingStore)
            XCTAssertEqual($0.resourceURL, storeURL)
            XCTAssertNotNil($0.underlyingError)
        }
    }

    func testEmptyCatalogFailsRepresentativeDataValidation() throws {
        let directory = try makeTemporaryDirectory()
        let emptyStoreURL = directory.appendingPathComponent("Empty.sqlite")
        _ = try PersistenceBootstrap.make(configuration: .init(
            resolver: .bundle(.pokedexCore),
            pokedexStore: .sqlite(emptyStoreURL),
            userDataStore: .inMemory,
            validatesBundledCatalog: false
        ))
        let resolver = PersistenceBootstrap.ResourceResolver.bundle(.pokedexCore)
        let configuration = PersistenceBootstrap.Configuration(
            resolver: .init(
                modelURL: resolver.modelURL,
                resourceURL: { _, extensionName in
                    extensionName == "sqlite" ? emptyStoreURL : nil
                }
            ),
            pokedexStore: .bundledCatalog,
            userDataStore: .inMemory,
            validatesBundledCatalog: true
        )

        assertBootstrapError(try PersistenceBootstrap.make(configuration: configuration)) {
            XCTAssertEqual($0.stage, .validatingStore)
            XCTAssertNotNil($0.underlyingError)
        }
    }

    func testCacheReturnsSameStoresAndLoadsOnlyOnce() throws {
        let stores = try PersistenceBootstrap.makeInMemoryForTesting()
        var loadCount = 0
        let cache = PersistenceBootstrap.Cache {
            loadCount += 1
            return stores
        }

        XCTAssertTrue(try cache.load() === stores)
        XCTAssertTrue(try cache.load() === stores)
        XCTAssertEqual(loadCount, 1)
    }

    func testConcurrentCacheCallersWaitForSingleSynchronousLoad() throws {
        let stores = try PersistenceBootstrap.makeInMemoryForTesting()
        let queue = DispatchQueue(label: "PersistenceBootstrapTests", attributes: .concurrent)
        let group = DispatchGroup()
        let resultLock = NSLock()
        var identifiers: [ObjectIdentifier] = []
        var errors: [Error] = []
        var loadCount = 0
        let cache = PersistenceBootstrap.Cache {
            loadCount += 1
            return stores
        }

        for _ in 0..<20 {
            group.enter()
            queue.async {
                defer { group.leave() }
                do {
                    let value = try cache.load()
                    resultLock.lock()
                    identifiers.append(ObjectIdentifier(value))
                    resultLock.unlock()
                } catch {
                    resultLock.lock()
                    errors.append(error)
                    resultLock.unlock()
                }
            }
        }
        XCTAssertEqual(group.wait(timeout: .now() + 5), .success)

        XCTAssertTrue(errors.isEmpty)
        XCTAssertEqual(Set(identifiers).count, 1)
        XCTAssertEqual(loadCount, 1)
    }

    func testCachePreservesFailureWithoutImplicitRetry() {
        var loadCount = 0
        let cache = PersistenceBootstrap.Cache {
            loadCount += 1
            throw TestError()
        }

        XCTAssertThrowsError(try cache.load())
        XCTAssertThrowsError(try cache.load())
        XCTAssertEqual(loadCount, 1)
    }

    func testProductionCacheCanBeIsolatedForSingletonTests() throws {
        let stores = try PersistenceBootstrap.makeInMemoryForTesting()
        PersistenceBootstrap.replaceProductionCacheForTesting(.init { stores })

        XCTAssertTrue(try PersistenceBootstrap.production() === stores)
        XCTAssertTrue(try PersistenceBootstrap.production() === stores)
    }

    func testUnavailableDataStorePropagatesThroughExistingThrowingBoundary() {
        let dataStore = DataStore(error: TestError())

        XCTAssertThrowsError(
            try dataStore.fetch(Pokemon.self, filter: .default(for: .national))
        ) { error in
            XCTAssertTrue(error is TestError)
        }
    }

    private func makeTemporaryDirectory() throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        addTeardownBlock {
            try? FileManager.default.removeItem(at: directory)
        }
        return directory
    }

    private func assertBootstrapError<T>(
        _ expression: @autoclosure () throws -> T,
        assertions: (PersistenceBootstrapError) -> Void
    ) {
        XCTAssertThrowsError(try expression()) { error in
            guard let bootstrapError = error as? PersistenceBootstrapError else {
                return XCTFail("Expected PersistenceBootstrapError, received \(type(of: error))")
            }
            assertions(bootstrapError)
        }
    }
}
