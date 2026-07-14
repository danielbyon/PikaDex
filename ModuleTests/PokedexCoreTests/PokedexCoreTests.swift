//
//  PokedexCoreTests.swift
//
//
//  Created by Daniel Byon on 9/20/22.
//

import CoreData
import XCTest

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

    private let dataStore = DataStore.pokedex

    func testBundledDatabaseLoads() {
        XCTAssertNotNil(Bundle.pokedexCore.url(forResource: "Pokedex", withExtension: "momd"))
        XCTAssertNotNil(Bundle.pokedexCore.url(forResource: "Pokedex", withExtension: "sqlite"))
        _ = NSPersistentContainer.pokedexContainer
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
        let nationalRequest = AbilityFilter(game: .national).makeFetchRequest(dataStore)
        let scarletRequest = AbilityFilter(game: .scarlet).makeFetchRequest(dataStore)

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
