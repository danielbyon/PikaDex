//
//  QueryLayerTests.swift
//  PokedexCoreTests
//
//  Verifies the request/execution boundary and the observable query lifecycle.
//

import CoreData
import XCTest

@testable import PokedexCore

final class QueryLayerTests: XCTestCase {

    fileprivate struct FixtureError: Error { }

    func testInitialFetchAndFilterChangePublishDeterministicStates() throws {
        let stores = try PersistenceBootstrap.makeInMemoryForTesting()
        try stores.userData.save(caughtPokemon(name: "Bulbasaur", index: 1, game: .national))
        try stores.userData.save(caughtPokemon(name: "Sprigatito", index: 906, game: .scarlet))
        let observer = QueryObserver<CaughtPokemon>()
        var states: [QueryState] = []
        observer.stateDidChange = { states.append($0) }

        observer.update(filter: CaughtPokemonFilter(game: .national), dataStore: stores.userData)

        XCTAssertEqual(states, [.loading, .loaded])
        XCTAssertEqual(observer.results.state, .loaded)
        XCTAssertEqual(observer.results.map(\.pokemonName), ["Bulbasaur"])
        let nationalController = try XCTUnwrap(observer.controller)

        states.removeAll()
        observer.update(filter: CaughtPokemonFilter(game: .scarlet), dataStore: stores.userData)

        XCTAssertEqual(states, [.loading, .loaded])
        XCTAssertEqual(observer.results.map(\.pokemonName), ["Sprigatito"])
        XCTAssertFalse(observer.controller === nationalController)
        XCTAssertNil(nationalController.delegate)
    }

    func testUnchangedInputAndEquivalentStoreWrapperReuseController() throws {
        let stores = try PersistenceBootstrap.makeInMemoryForTesting()
        try stores.userData.save(caughtPokemon(name: "Bulbasaur", index: 1, game: .national))
        let equivalentStore = DataStore(context: stores.userDataContainer.viewContext)
        let observer = QueryObserver<CaughtPokemon>()
        var states: [QueryState] = []
        observer.stateDidChange = { states.append($0) }

        observer.update(filter: CaughtPokemonFilter(game: .national), dataStore: stores.userData)
        let originalController = try XCTUnwrap(observer.controller)
        states.removeAll()

        observer.update(filter: CaughtPokemonFilter(game: .national), dataStore: stores.userData)
        observer.update(filter: CaughtPokemonFilter(game: .national), dataStore: equivalentStore)

        XCTAssertTrue(observer.controller === originalController)
        XCTAssertTrue(states.isEmpty)
    }

    func testStoreReplacementRetainsRowsWhileLoadingAndDetachesOldController() throws {
        let stores = try PersistenceBootstrap.makeInMemoryForTesting()
        try stores.userData.save(caughtPokemon(name: "Bulbasaur", index: 1, game: .national))
        let replacementContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        replacementContext.persistentStoreCoordinator = stores.userDataContainer.persistentStoreCoordinator
        let replacementStore = DataStore(context: replacementContext)
        let observer = QueryObserver<CaughtPokemon>()

        observer.update(filter: CaughtPokemonFilter(game: .national), dataStore: stores.userData)
        let firstController = try XCTUnwrap(observer.controller)
        var loadingRows: [String] = []
        observer.stateDidChange = { state in
            if state == .loading {
                loadingRows = observer.results.map(\.pokemonName)
            }
        }

        observer.update(filter: CaughtPokemonFilter(game: .national), dataStore: replacementStore)

        XCTAssertEqual(loadingRows, ["Bulbasaur"])
        XCTAssertEqual(observer.results.map(\.pokemonName), ["Bulbasaur"])
        XCTAssertNil(firstController.delegate)

    }

    func testFetchedResultsUpdatesAfterInsertAndDelete() throws {
        let stores = try PersistenceBootstrap.makeInMemoryForTesting()
        try stores.userData.save(caughtPokemon(name: "Bulbasaur", index: 1, game: .national))
        let observer = QueryObserver<CaughtPokemon>()
        observer.update(filter: CaughtPokemonFilter(game: .national), dataStore: stores.userData)

        try stores.userData.save(caughtPokemon(name: "Charmander", index: 4, game: .national))
        XCTAssertEqual(observer.results.map(\.pokemonName), ["Bulbasaur", "Charmander"])

        try stores.userData.remove(
            CaughtPokemon.self,
            filter: CaughtPokemonFilter(caughtPokemon: observer.results[0])
        )
        XCTAssertEqual(observer.results.map(\.pokemonName), ["Charmander"])
        XCTAssertEqual(observer.results.state, .loaded)
    }

    func testUnavailableStoreRetainsRowsAndSuccessfulRetryClearsFailure() throws {
        let stores = try PersistenceBootstrap.makeInMemoryForTesting()
        try stores.userData.save(caughtPokemon(name: "Bulbasaur", index: 1, game: .national))
        let observer = QueryObserver<CaughtPokemon>()
        observer.update(filter: CaughtPokemonFilter(game: .national), dataStore: stores.userData)

        observer.update(
            filter: CaughtPokemonFilter(game: .national),
            dataStore: DataStore(error: FixtureError())
        )

        XCTAssertEqual(observer.results.state, .failed(.unavailableStore))
        XCTAssertEqual(observer.results.map(\.pokemonName), ["Bulbasaur"])
        XCTAssertNotNil(observer.diagnosticError)

        observer.update(filter: CaughtPokemonFilter(game: .national), dataStore: stores.userData)

        XCTAssertEqual(observer.results.state, .loaded)
        XCTAssertEqual(observer.results.map(\.pokemonName), ["Bulbasaur"])
        XCTAssertNil(observer.diagnosticError)
    }

    func testInitialUnavailableStoreFailureHasNoRows() {
        let observer = QueryObserver<CaughtPokemon>()

        observer.update(
            filter: CaughtPokemonFilter(game: .national),
            dataStore: DataStore(error: FixtureError())
        )

        XCTAssertEqual(observer.results.state, .failed(.unavailableStore))
        XCTAssertTrue(observer.results.isEmpty)
    }

    func testUnsupportedAndGenericRequestFailuresMapToStableValues() throws {
        let stores = try PersistenceBootstrap.makeInMemoryForTesting()
        let unsupportedObserver = QueryObserver<MoveDetail>()
        unsupportedObserver.update(filter: .default, dataStore: stores.pokedex)
        XCTAssertEqual(unsupportedObserver.results.state, .failed(.unsupportedFilter))
        XCTAssertTrue(unsupportedObserver.diagnosticError is QueryError)

        let constructionObserver = QueryObserver<FailingRequestValue>()
        constructionObserver.update(filter: .default, dataStore: stores.userData)
        XCTAssertEqual(constructionObserver.results.state, .failed(.requestConstruction))
        XCTAssertTrue(constructionObserver.diagnosticError is FixtureError)
    }

    func testCoreDataFetchFailureMapsToStableValue() throws {
        let stores = try PersistenceBootstrap.makeInMemoryForTesting()
        let observer = QueryObserver<CaughtPokemon>()

        observer.update(
            filter: CaughtPokemonFilter(game: .national),
            dataStore: DataStore(
                context: stores.userDataContainer.viewContext,
                observationFetch: { _ in throw FixtureError() }
            )
        )

        XCTAssertEqual(observer.results.state, .failed(.fetch))
        XCTAssertTrue(observer.results.isEmpty)
        XCTAssertTrue(observer.diagnosticError is FixtureError)
    }

    func testObservedDefaultsDoNotMutateOneShotRequestDefaults() throws {
        let oneShotRequest = CaughtPokemonFilter(game: .national).makeFetchRequest()
        XCTAssertEqual(oneShotRequest.fetchBatchSize, 0)
        XCTAssertTrue(oneShotRequest.returnsObjectsAsFaults)

        let stores = try PersistenceBootstrap.makeInMemoryForTesting()
        let observer = QueryObserver<CaughtPokemon>()
        observer.update(filter: CaughtPokemonFilter(game: .national), dataStore: stores.userData)
        let observedRequest = try XCTUnwrap(observer.controller?.fetchRequest)

        XCTAssertEqual(observedRequest.fetchBatchSize, DatabaseConstants.fetchBatchSize)
        XCTAssertFalse(observedRequest.returnsObjectsAsFaults)
    }

    func testPokemonRequestPreservesSearchSortBatchAndPrefetchBehavior() {
        let request = PokemonFilter(
            game: .national,
            pokedex: .national,
            sortBy: .name,
            sortOrder: .descending,
            query: .exact("Mr. Mime")
        ).makeFetchRequest()

        XCTAssertTrue(request.predicate?.predicateFormat.contains("i_gameIndex") == true)
        XCTAssertTrue(request.predicate?.predicateFormat.contains("z_canonicalName ==") == true)
        XCTAssertEqual(request.sortDescriptors?.map(\.key), [#keyPath(StoredPokemon.z_name)])
        XCTAssertEqual(request.sortDescriptors?.map(\.ascending), [false])
        XCTAssertEqual(request.fetchBatchSize, DatabaseConstants.fetchBatchSize)
        XCTAssertEqual(request.relationshipKeyPathsForPrefetching, [#keyPath(StoredPokemon.z_pokedexNumbers)])
    }

    func testDetailAndRelationshipHeavyRequestsPreserveSpecialSettings() {
        let detailRequest = PokemonDetailFilter(name: "Bulbasaur", game: .national).makeFetchRequest()
        XCTAssertEqual(detailRequest.fetchLimit, 1)
        XCTAssertFalse(detailRequest.returnsObjectsAsFaults)
        XCTAssertEqual(detailRequest.sortDescriptors?.map(\.key), [#keyPath(StoredPokemon.z_index)])
        XCTAssertTrue(detailRequest.predicate?.predicateFormat.contains("i_gameIndex") == true)
        XCTAssertTrue(detailRequest.relationshipKeyPathsForPrefetching?.contains(#keyPath(StoredPokemon.z_forms.z_baseStats)) == true)

        let formRequest = PokemonDetailFormFilter(game: .national).makeFetchRequest()
        XCTAssertEqual(formRequest.fetchBatchSize, DatabaseConstants.fetchBatchSize)
        XCTAssertFalse(formRequest.returnsObjectsAsFaults)
        XCTAssertEqual(formRequest.sortDescriptors?.map(\.key), [
            #keyPath(StoredPokemonForm.i_pokemonIndex),
            #keyPath(StoredPokemonForm.i_formIndex)
        ])

        let locationRequest = LocationPokemonFilter.default.makeFetchRequest()
        XCTAssertFalse(locationRequest.returnsObjectsAsFaults)
        XCTAssertEqual(locationRequest.relationshipKeyPathsForPrefetching, [
            #keyPath(StoredLocationPokemon.z_location),
            #keyPath(StoredLocationPokemon.z_pokemon),
            #keyPath(StoredLocationPokemon.z_pokemon.z_forms)
        ])
    }

    func testSearchableAndExplicitlyTunedRequestsPreserveBehavior() {
        let locationRequest = LocationFilter(game: .scarlet, query: .contains("Area Zero")).makeFetchRequest()
        XCTAssertEqual(locationRequest.fetchBatchSize, DatabaseConstants.fetchBatchSize)
        XCTAssertTrue(locationRequest.returnsObjectsAsFaults)
        XCTAssertTrue(locationRequest.predicate?.predicateFormat.contains("CONTAINS") == true)
        XCTAssertEqual(locationRequest.relationshipKeyPathsForPrefetching, [#keyPath(StoredLocation.z_maps)])

        let abilityRequest = AbilityFilter(game: .national).makeFetchRequest()
        XCTAssertFalse(abilityRequest.returnsObjectsAsFaults)
        XCTAssertEqual(abilityRequest.sortDescriptors?.map(\.key), [#keyPath(StoredAbility.z_name)])

        let machineRequest = MachineFilter(game: .national).makeFetchRequest()
        XCTAssertFalse(machineRequest.returnsObjectsAsFaults)
        XCTAssertEqual(machineRequest.relationshipKeyPathsForPrefetching, [#keyPath(StoredMachine.z_move)])
    }

    func testRemainingNontrivialRequestShapesPreserveTheirSpecialSettings() {
        let abilityFormsRequest = AbilityPokemonFormFilter.default.makeFetchRequest()
        XCTAssertEqual(abilityFormsRequest.fetchBatchSize, DatabaseConstants.fetchBatchSize)
        XCTAssertFalse(abilityFormsRequest.returnsObjectsAsFaults)
        XCTAssertEqual(abilityFormsRequest.relationshipKeyPathsForPrefetching, [#keyPath(StoredPokemonForm.z_pokemon)])
        XCTAssertEqual(abilityFormsRequest.sortDescriptors?.map(\.key), [
            #keyPath(StoredPokemonForm.i_pokemonIndex),
            #keyPath(StoredPokemonForm.i_formIndex)
        ])

        let itemRequest = ItemFilter(game: .national).makeFetchRequest()
        XCTAssertEqual(itemRequest.relationshipKeyPathsForPrefetching, [
            #keyPath(StoredItem.bagInfo),
            #keyPath(StoredItem.berryInfo)
        ])
        XCTAssertEqual(itemRequest.sortDescriptors?.count, 2)

        let caughtRequest = CaughtPokemonFilter(game: .national).makeFetchRequest()
        XCTAssertEqual(caughtRequest.sortDescriptors?.map(\.key), [
            #keyPath(StoredCaughtPokemon.i_gameIndex),
            #keyPath(StoredCaughtPokemon.z_index),
            #keyPath(StoredCaughtPokemon.z_formName)
        ])

        let moveRequest = MoveFilter(game: .scarlet, type: .fire, query: .contains("flame")).makeFetchRequest()
        XCTAssertTrue(moveRequest.predicate?.predicateFormat.contains("z_type") == true)
        XCTAssertTrue(moveRequest.predicate?.predicateFormat.contains("CONTAINS") == true)
        XCTAssertEqual(moveRequest.sortDescriptors?.map(\.key), [#keyPath(StoredMove.z_name)])

        let learnsetRequests: [NSFetchRequest<StoredLearnsetEntry>] = [
            LearnsetEntryFilter.default.makeFetchRequest(),
            LearnsetBreedingEntryFilter.default.makeFetchRequest(),
            LearnsetLevelEntryFilter.default.makeFetchRequest(),
            LearnsetMachineEntryFilter.default.makeFetchRequest(),
            LearnsetTutoringEntryFilter.default.makeFetchRequest()
        ]
        for request in learnsetRequests {
            XCTAssertFalse(request.sortDescriptors?.isEmpty ?? true)
            XCTAssertFalse(request.relationshipKeyPathsForPrefetching?.isEmpty ?? true)
            XCTAssertTrue(request.predicate?.predicateFormat.contains("FALSEPREDICATE") == true)
        }
    }

    func testOneShotOperationsAreSafeWhenAlreadyOnMainContextQueue() throws {
        let stores = try PersistenceBootstrap.makeInMemoryForTesting()
        let context = stores.userDataContainer.viewContext
        let caughtPokemon = try caughtPokemon(name: "Bulbasaur", index: 1, game: .national)

        try context.performAndWait {
            try stores.userData.save(caughtPokemon)
            XCTAssertEqual(
                try stores.userData.fetch(CaughtPokemon.self, filter: .init(game: .national)).count,
                1
            )
        }
    }

    private func caughtPokemon(name: String, index: Int, game: Game) throws -> CaughtPokemon {
        try JSONDecoder().decode(
            CaughtPokemon.self,
            from: Data(
                #"{"pokemonName":"\#(name)","formName":"\#(name)","index":\#(index),"game":"\#(game.rawValue)"}"#.utf8
            )
        )
    }
}

private struct FailingRequestFilter: QueryFilter {
    typealias ResultType = StoredCaughtPokemon

    static let `default` = Self()

    func makeFetchRequest() throws -> NSFetchRequest<StoredCaughtPokemon> {
        throw QueryLayerTests.FixtureError()
    }
}

private struct FailingRequestValue: Queryable {
    typealias Filter = FailingRequestFilter

    init(result: StoredCaughtPokemon) { }
}
