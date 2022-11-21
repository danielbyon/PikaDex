//
//  PokemonDetailFilter.swift
//  
//
//  Created by Daniel Byon on 9/21/22.
//

import CoreData
import Foundation

public struct PokemonDetailFilter: QueryFilter {

    // MARK: Properties

    public typealias ResultType = StoredPokemon

    public static var `default`: PokemonDetailFilter {
        .init(name: "k", game: .national)
    }

    public var name: String
    public var game: Game

    // MARK: Init

    public init(
        name: String,
        game: Game
    ) {
        self.name = name
        self.game = game
    }

    public init(pokemon: Pokemon) {
        self.init(
            name: pokemon.name,
            game: pokemon.game
        )
    }

    // MARK: Functions

    public func makeFetchRequest(_ dataStore: DataStore) -> NSFetchRequest<ResultType> {
        let request: NSFetchRequest<StoredPokemon> = StoredPokemon.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "\(#keyPath(StoredPokemon.z_name)) LIKE[cd] %@ AND \(#keyPath(StoredPokemon.i_gameIndex)) == %d", name, game.index)
        request.relationshipKeyPathsForPrefetching = [
            #keyPath(StoredPokemon.z_pokedexNumbers),
            #keyPath(StoredPokemon.z_forms),
            #keyPath(StoredPokemon.z_forms.z_baseStats),
            #keyPath(StoredPokemon.z_forms.z_evolutions),
            #keyPath(StoredPokemon.z_forms.z_evolutions.ability),
            #keyPath(StoredPokemon.z_forms.z_evolutions.item),
            #keyPath(StoredPokemon.z_forms.z_evolutions.move),
            #keyPath(StoredPokemon.z_forms.z_evolutions.pokemon),
            #keyPath(StoredPokemon.z_forms.z_evYield),
            #keyPath(StoredPokemon.z_forms.z_hiddenAbility),
            #keyPath(StoredPokemon.z_forms.z_primaryAbility),
            #keyPath(StoredPokemon.z_forms.z_secondaryAbility),
            #keyPath(StoredPokemon.z_locationPokemons),
            "z_locationPokemons.z_location"
        ]
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(StoredPokemon.z_index), ascending: true)]
        return request
    }

}

extension PokemonDetailFilter: Codable { }

extension PokemonDetailFilter: Hashable { }
