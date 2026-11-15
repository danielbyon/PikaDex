//
//  PokedexCoreTests.swift
//
//
//  Created by Daniel Byon on 9/20/22.
//

import CoreData
import Foundation
import XCTest

#if canImport(UIKit)
import PokedexResources
import UIKit
#endif

@testable import PokedexCore

/// Counts for the checked-in generated database snapshot.
///
/// Update this manifest deliberately when new source data is imported and a new
/// database snapshot is generated. Durable integrity tests below intentionally
/// do not depend on these counts.
private enum CurrentGeneratedDatabaseSnapshot {
    static let abilities = 306
    static let items = 1_260
    static let locations = 212
    static let moves = 934
    static let pokemon = 1_025
}

final class PokedexCoreTests: XCTestCase {

    private static let storesResult: Result<PersistenceStores, Error> = Result {
        try PersistenceBootstrap.makeBundledCatalogForTesting()
    }

    private var dataStore: DataStore!

    override func setUpWithError() throws {
        dataStore = try Self.storesResult.get().pokedex
    }

    func testBundledDatabaseLoads() {
        XCTAssertNotNil(Bundle.pokedexCore.url(forResource: "Pokedex", withExtension: "momd"))
        XCTAssertNotNil(Bundle.pokedexCore.url(forResource: "Pokedex", withExtension: "sqlite"))
        let stores = try? Self.storesResult.get()
        XCTAssertEqual(stores?.pokedexContainer.persistentStoreCoordinator.persistentStores.count, 1)
    }

    // MARK: Durable integrity tests

    func testNationalPokemonDatasetIsCompleteAndContiguous() throws {
        let pokemon = try dataStore.fetch(Pokemon.self, filter: .default(for: .national))

        XCTAssertFalse(pokemon.isEmpty)
        XCTAssertTrue(pokemon.allSatisfy { $0.game == .national })
        XCTAssertEqual(Set(pokemon.map(\.index)).count, pokemon.count)
        XCTAssertEqual(pokemon.map(\.index), Array(1...pokemon.count))
        XCTAssertEqual(pokemon.first?.name, "Bulbasaur")
        XCTAssertEqual(pokemon.last?.name, "Pecharunt")
    }

    func testNationalDetailUsesDirectDatasetFilter() throws {
        let bulbasaur = try dataStore.fetch(
            PokemonDetail.self,
            filter: PokemonDetailFilter(name: "Bulbasaur", game: .national)
        )

        XCTAssertEqual(bulbasaur.count, 1)
        XCTAssertEqual(bulbasaur.first?.game, .national)
        XCTAssertEqual(bulbasaur.first?.index, 1)
    }

    func testNationalGameKeyedQueriesReturnOnlyNationalRows() throws {
        let items = try dataStore.fetch(Item.self, filter: ItemFilter(game: .national))
        let locations = try dataStore.fetch(Location.self, filter: LocationFilter(game: .national))
        let moves = try dataStore.fetch(Move.self, filter: MoveFilter(game: .national))

        XCTAssertFalse(items.isEmpty)
        XCTAssertFalse(locations.isEmpty)
        XCTAssertFalse(moves.isEmpty)
        XCTAssertTrue(items.allSatisfy { $0.game == .national })
        XCTAssertTrue(locations.allSatisfy { $0.game == .national })
        XCTAssertTrue(moves.allSatisfy { $0.game == .national })
    }

    func testNationalAbilitiesUseAuthoritativeNationalDescriptions() throws {
        let abilities = try dataStore.fetch(Ability.self, filter: AbilityFilter(game: .national))

        XCTAssertFalse(abilities.isEmpty)
        XCTAssertTrue(abilities.allSatisfy { ability in
            guard let description = ability[.national] else { return false }
            return !description.isEmpty
        })
    }

    func testNationalAbilityFilterDoesNotApplyReleasedGenerationCutoff() {
        let nationalRequest = AbilityFilter(game: .national).makeFetchRequest()
        let scarletRequest = AbilityFilter(game: .scarlet).makeFetchRequest()

        XCTAssertEqual((nationalRequest.predicate as? NSCompoundPredicate)?.subpredicates.count, 0)
        XCTAssertEqual((scarletRequest.predicate as? NSCompoundPredicate)?.subpredicates.count, 1)
    }

    // MARK: Current generated-database snapshot

    func testCurrentGeneratedDatabaseSnapshotCounts() throws {
        XCTAssertEqual(
            try dataStore.fetch(Ability.self, filter: AbilityFilter(game: .national)).count,
            CurrentGeneratedDatabaseSnapshot.abilities
        )
        XCTAssertEqual(
            try dataStore.fetch(Item.self, filter: ItemFilter(game: .national)).count,
            CurrentGeneratedDatabaseSnapshot.items
        )
        XCTAssertEqual(
            try dataStore.fetch(Location.self, filter: LocationFilter(game: .national)).count,
            CurrentGeneratedDatabaseSnapshot.locations
        )
        XCTAssertEqual(
            try dataStore.fetch(Move.self, filter: MoveFilter(game: .national)).count,
            CurrentGeneratedDatabaseSnapshot.moves
        )
        XCTAssertEqual(
            try dataStore.fetch(Pokemon.self, filter: .default(for: .national)).count,
            CurrentGeneratedDatabaseSnapshot.pokemon
        )
    }
}

#if canImport(UIKit)
final class PokedexResourcesBundleTests: XCTestCase {

    func testResourcesBundleLoadsRareCandyAsset() {
        let bundle = Bundle.resources

        XCTAssertEqual(bundle.bundleIdentifier, "com.danielbyon.PokedexResources")
        XCTAssertNotNil(UIImage(named: "rare-candy", in: bundle, compatibleWith: nil))
    }
}
#endif

final class TeamPersistenceWriterTests: XCTestCase {

    func testShutdownDiscardsPendingSnapshotBeforePostShutdownFlush() {
        let storage = WriterRecordingTeamStorage()
        let writer = TeamPersistenceWriter(
            storage: storage,
            notificationCenter: NotificationCenter(),
            debounceInterval: 3_600
        )
        writer.submit([.sword: [Team(name: "Pending")]])

        writer.shutdown()
        writer.flushPendingWrites()

        XCTAssertEqual(storage.saveCount, 0)
        XCTAssertNil(storage.savedTeams(for: .sword))
    }
}

/// Records storage writes so writer shutdown can be checked without waiting for its debounce timer.
private final class WriterRecordingTeamStorage: TeamStorage, @unchecked Sendable {
    // The lock protects every access to the recorded teams and save count.
    private let lock = NSLock()
    private var teamsByGame: [Game: [Team]] = [:]
    private var saves = 0

    var saveCount: Int {
        lock.lock()
        defer { lock.unlock() }
        return saves
    }

    func loadTeams(forGame game: Game) -> [Team]? {
        lock.lock()
        defer { lock.unlock() }
        return teamsByGame[game]
    }

    func saveTeams(_ teams: [Team], forGame game: Game) {
        lock.lock()
        defer { lock.unlock() }
        teamsByGame[game] = teams
        saves += 1
    }

    func savedTeams(for game: Game) -> [Team]? {
        lock.lock()
        defer { lock.unlock() }
        return teamsByGame[game]
    }
}

final class PokemonTypeRegressionTests: XCTestCase {

    func testTypeAvailabilityMatchesGenerations() {
        let generationI = PokemonType.allTypes(for: .i)
        XCTAssertEqual(generationI.count, 15)
        XCTAssertFalse(generationI.contains(.dark))
        XCTAssertFalse(generationI.contains(.steel))
        XCTAssertFalse(generationI.contains(.fairy))

        let generationII = PokemonType.allTypes(for: .ii)
        XCTAssertEqual(generationII.count, 17)
        XCTAssertTrue(generationII.contains(.dark))
        XCTAssertTrue(generationII.contains(.steel))
        XCTAssertFalse(generationII.contains(.fairy))

        let generationVI = PokemonType.allTypes(for: .vi)
        XCTAssertEqual(generationVI.count, 18)
        XCTAssertTrue(generationVI.contains(.fairy))
    }

    func testRepresentativeMatchupsPreserveSuperEffectiveAndImmuneValues() {
        XCTAssertEqual(PokemonType.fire.offense(for: .grass, generation: .vi), 2)
        XCTAssertEqual(PokemonType.normal.offense(for: .ghost, generation: .vi), 0)
    }

    func testDualTypeDefenseMultipliersCombine() {
        let effectiveness = TypeEffectiveness(primary: .fire, secondary: .flying)
        XCTAssertEqual(effectiveness.defense(for: .rock, generation: .vi), 4)
    }
}

final class AppGroupTeamStorageCompatibilityTests: XCTestCase {

    func testAppGroupSuiteNameRemainsStable() {
        XCTAssertEqual(UserDefaults.appGroupSuiteName, "group.com.danielbyon.pokepedia")
    }

    func testReadsLegacyTeamsFromExistingGameKey() throws {
        let suiteName = "com.danielbyon.pokedex.tests.team-storage.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let identifier = "00000000-0000-0000-0000-000000000001"
        let legacyJSON = #"[{"name":"Legacy team","members":[],"internalID":"00000000-0000-0000-0000-000000000001"}]"#
        defaults.set(Data(legacyJSON.utf8), forKey: "teams-sword")

        let storage = AppGroupTeamStorage(suiteName: suiteName)
        let teams = try XCTUnwrap(storage.loadTeams(forGame: .sword))

        XCTAssertEqual(teams.count, 1)
        XCTAssertEqual(teams[0].name, "Legacy team")
        XCTAssertEqual(teams[0].internalID, UUID(uuidString: identifier))
    }

    func testWritesJSONUnderTheExistingGameKey() throws {
        let suiteName = "com.danielbyon.pokedex.tests.team-storage.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let storage = AppGroupTeamStorage(suiteName: suiteName)
        let internalID = try XCTUnwrap(UUID(uuidString: "00000000-0000-0000-0000-000000000002"))
        let team = Team(
            name: "Saved team",
            members: [],
            internalID: internalID
        )

        storage.saveTeams([team], forGame: .sword)

        let data = try XCTUnwrap(defaults.data(forKey: "teams-sword"))
        let decodedTeams = try JSONDecoder().decode([Team].self, from: data)
        XCTAssertEqual(decodedTeams, [team])
    }

    func testConcurrentAdaptersKeepReadableSnapshots() async throws {
        let suiteName = "com.danielbyon.pokedex.tests.team-storage.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let storages = [
            AppGroupTeamStorage(suiteName: suiteName),
            AppGroupTeamStorage(suiteName: suiteName)
        ]
        let validNames = Set((0..<64).flatMap { worker in
            (0..<32).map { "Team \(worker)-\($0)" }
        })
        let invalidReadCount = await withTaskGroup(of: Bool.self, returning: Int.self) { group in
            for index in 0..<64 {
                group.addTask {
                    let storage = storages[index % storages.count]
                    for iteration in 0..<32 {
                        storage.saveTeams([Team(name: "Team \(index)-\(iteration)")], forGame: .sword)
                        let snapshot = storage.loadTeams(forGame: .sword)
                        guard snapshot?.count == 1,
                              let name = snapshot?.first?.name,
                              validNames.contains(name)
                        else { return false }
                    }
                    return true
                }
            }

            var invalidReads = 0
            for await isValid in group where !isValid {
                invalidReads += 1
            }

            return invalidReads
        }

        XCTAssertEqual(invalidReadCount, 0)
        let finalSnapshot = storages[0].loadTeams(forGame: .sword)
        XCTAssertEqual(finalSnapshot?.count, 1)
        XCTAssertTrue(finalSnapshot?.first.map { validNames.contains($0.name) } == true)
    }
}
