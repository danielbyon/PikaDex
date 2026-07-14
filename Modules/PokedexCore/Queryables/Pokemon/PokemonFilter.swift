//
//  PokemonFilter.swift
//  Pokedex
//
//  Created by Daniel Byon on 10/19/21.
//  Copyright © 2021 Daniel Byon. All rights reserved.
//

import CoreData
import Foundation

public struct PokemonFilter: SearchableFilter {

    // MARK: Nested Types

    public enum SortBy: String, CaseIterable, Codable, Hashable {
        case name
        case number
    }

    private enum CodingKeys: String, CodingKey {
        case game
        case pokedex
        case sortBy
        case sortOrder
        // query not included
    }

    // MARK: Properties

    public typealias ResultType = StoredPokemon

    public static var `default`: PokemonFilter {
        .default(for: .national)
    }

    public var game: Game
    public var pokedex: Pokedex
    public var sortBy: SortBy
    public var sortOrder: SortOrder
    public var query: SearchQuery

    // MARK: Init

    public init(
        game: Game,
        pokedex: Pokedex,
        sortBy: SortBy = .number,
        sortOrder: SortOrder = .ascending,
        query: SearchQuery = .empty
    ) {
        self.game = game
        self.pokedex = pokedex
        self.sortBy = sortBy
        self.sortOrder = sortOrder
        self.query = query
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        game = try container.decode(Game.self, forKey: .game)
        pokedex = try container.decode(Pokedex.self, forKey: .pokedex)
        sortBy = try container.decode(SortBy.self, forKey: .sortBy)
        sortOrder = try container.decode(SortOrder.self, forKey: .sortOrder)
        query = .empty
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(game, forKey: .game)
        try container.encode(pokedex, forKey: .pokedex)
        try container.encode(sortBy, forKey: .sortBy)
        try container.encode(sortOrder, forKey: .sortOrder)
    }

    // MARK: Functions

    public static func `default`(for game: Game) -> PokemonFilter {
        .init(game: game, pokedex: game.defaultPokedex)
    }

    public func makeFetchRequest() -> NSFetchRequest<StoredPokemon> {
        let fetchRequest = StoredPokemon.fetchRequest() as NSFetchRequest<StoredPokemon>

        var predicates = [
            NSPredicate(format: "\(#keyPath(StoredPokemon.i_gameIndex)) == %d", game.databaseIndex),
            NSPredicate(format: "\(pokedex.keyPath) != -1")
        ]

        if !query.isEmpty {
            switch query {
            case .contains(let string):
                predicates.append(.init(format: "\(#keyPath(StoredPokemon.z_canonicalName)) CONTAINS %@", string.normalizedForSearch))
            case .exact(let string):
                predicates.append(.init(format: "\(#keyPath(StoredPokemon.z_canonicalName)) == %@", string.normalizedForSearch))
            }
        }

        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        let ascending = sortOrder == .ascending
        switch sortBy {
        case .number:
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: pokedex.keyPath, ascending: ascending)]
        case .name:
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(StoredPokemon.z_name), ascending: ascending)]
        }

        fetchRequest.fetchBatchSize = DatabaseConstants.fetchBatchSize
        fetchRequest.relationshipKeyPathsForPrefetching = [
            #keyPath(StoredPokemon.z_pokedexNumbers)
        ]
        return fetchRequest
    }

}

extension PokemonFilter: Codable { }

extension PokemonFilter: Hashable { }

private extension Pokedex {

    var keyPath: String {
        switch self {
        case .national:
            return #keyPath(StoredPokemon.z_pokedexNumbers.z_national)
        case .kanto:
            return #keyPath(StoredPokemon.z_pokedexNumbers.z_kanto)
        case .johto:
            return #keyPath(StoredPokemon.z_pokedexNumbers.z_johto)
        case .hoenn:
            return #keyPath(StoredPokemon.z_pokedexNumbers.z_hoenn)
        case .sinnoh:
            return #keyPath(StoredPokemon.z_pokedexNumbers.z_sinnoh)
        case .newJohto:
            return #keyPath(StoredPokemon.z_pokedexNumbers.z_newJohto)
        case .unova:
            return #keyPath(StoredPokemon.z_pokedexNumbers.z_unova)
        case .newUnova:
            return #keyPath(StoredPokemon.z_pokedexNumbers.z_newUnova)
        case .centralKalos:
            return #keyPath(StoredPokemon.z_pokedexNumbers.z_centralKalos)
        case .coastalKalos:
            return #keyPath(StoredPokemon.z_pokedexNumbers.z_coastalKalos)
        case .mountainKalos:
            return #keyPath(StoredPokemon.z_pokedexNumbers.z_mountainKalos)
        case .newHoenn:
            return #keyPath(StoredPokemon.z_pokedexNumbers.z_newHoenn)
        case .alola:
            return #keyPath(StoredPokemon.z_pokedexNumbers.z_alola)
        case .melemele:
            return #keyPath(StoredPokemon.z_pokedexNumbers.z_melemele)
        case .akala:
            return #keyPath(StoredPokemon.z_pokedexNumbers.z_akala)
        case .ulaula:
            return #keyPath(StoredPokemon.z_pokedexNumbers.z_ulaula)
        case .poni:
            return #keyPath(StoredPokemon.z_pokedexNumbers.z_poni)
        case .ultraAlola:
            return #keyPath(StoredPokemon.z_pokedexNumbers.z_ultraAlola)
        case .ultraMelemele:
            return #keyPath(StoredPokemon.z_pokedexNumbers.z_ultraMelemele)
        case .ultraAkala:
            return #keyPath(StoredPokemon.z_pokedexNumbers.z_ultraAkala)
        case .ultraUlaula:
            return #keyPath(StoredPokemon.z_pokedexNumbers.z_ultraUlaula)
        case .ultraPoni:
            return #keyPath(StoredPokemon.z_pokedexNumbers.z_ultraPoni)
        case .letsGoKanto:
            return #keyPath(StoredPokemon.z_pokedexNumbers.z_letsGoKanto)
        case .galar:
            return #keyPath(StoredPokemon.z_pokedexNumbers.z_galar)
        case .isleOfArmor:
            return #keyPath(StoredPokemon.z_pokedexNumbers.z_isleOfArmor)
        case .crownTundra:
            return #keyPath(StoredPokemon.z_pokedexNumbers.z_crownTundra)
        case .hisui:
            return #keyPath(StoredPokemon.z_pokedexNumbers.z_hisui)
        case .paldea:
            return #keyPath(StoredPokemon.z_pokedexNumbers.z_paldea)
        case .kitakami:
            return #keyPath(StoredPokemon.z_pokedexNumbers.z_kitakami)
        case .blueberry:
            return #keyPath(StoredPokemon.z_pokedexNumbers.z_blueberry)
        }
    }

}
