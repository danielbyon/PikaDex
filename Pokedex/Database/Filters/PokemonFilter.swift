//
//  PokemonFilter.swift
//  Pokedex
//
//  Created by Daniel Byon on 10/19/21.
//  Copyright © 2021 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

public struct PokemonFilter: QueryFilter {

    // MARK: Filters

    public static func all(game: Game) -> PokemonFilter {
        fatalError()
    }

    public static func pokemonList(
        game: Game,
        filterBy: FilterBy,
        sortBy: SortBy = .number,
        sortOrder: SortOrder = .ascending,
        searchString: String? = nil
    ) -> PokemonFilter {
        let fetchRequest = StoredPokemon.fetchRequest() as NSFetchRequest<StoredPokemon>
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "\(#keyPath(StoredPokemon.i_gameIndex)) == %d", game.index),
            NSPredicate(format: "\(filterBy.keyPath) != -1")
        ])

        let ascending = sortOrder == .ascending
        switch sortBy {
        case .number:
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: filterBy.keyPath, ascending: ascending)]
        case .name:
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(StoredPokemon.z_name), ascending: ascending)]
        }

        fetchRequest.relationshipKeyPathsForPrefetching = [
            #keyPath(StoredPokemon.z_pokedexNumbers),
            #keyPath(StoredPokemon.z_forms)
        ]

        return .init(fetchRequest: fetchRequest)
    }

    public static func byType(
        type: PokemonType,
        game: Game
    ) -> PokemonFilter {
        fatalError()
    }

    // MARK: Nested Types

    public struct FilterBy {
        public let title: String
        public let keyPath: String
    }

    public enum SortBy: String {
        case name
        case number
    }

    public enum SortOrder: String {
        case ascending
        case descending
    }

    // MARK: Properties

    public typealias ResultType = StoredPokemon

    private let fetchRequest: NSFetchRequest<StoredPokemon>

    // MARK: Functions

    public func makeFetchRequest(_ dataStore: DataStore) -> NSFetchRequest<StoredPokemon> {
        return fetchRequest
    }

}
