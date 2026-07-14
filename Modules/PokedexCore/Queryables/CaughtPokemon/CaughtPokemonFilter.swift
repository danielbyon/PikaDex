//
//  CaughtPokemonFilter.swift
//  
//
//  Created by Daniel Byon on 11/4/22.
//

import CoreData
import Foundation

public struct CaughtPokemonFilter: QueryFilter {

    public typealias ResultType = StoredCaughtPokemon

    public static var `default`: CaughtPokemonFilter {
        .init(game: .national)
    }

    private let pokemonName: String?
    private let formName: String?
    private let index: Int?
    private let game: Game

    public init(game: Game) {
        pokemonName = nil
        formName = nil
        index = nil
        self.game = game
    }

    public init(caughtPokemon: CaughtPokemon) {
        self.pokemonName = caughtPokemon.pokemonName
        self.formName = caughtPokemon.formName
        self.index = caughtPokemon.index
        self.game = caughtPokemon.game
    }

    public init(pokemon: Pokemon) {
        self.pokemonName = pokemon.name
        self.formName = pokemon.name
        self.index = pokemon.index
        self.game = pokemon.game
    }

    public init(pokemonDetail: PokemonDetail) {
        self.pokemonName = pokemonDetail.name
        self.formName = pokemonDetail.name
        self.index = pokemonDetail.index
        self.game = pokemonDetail.game
    }

    public func makeFetchRequest() -> NSFetchRequest<StoredCaughtPokemon> {
        let request: NSFetchRequest<StoredCaughtPokemon> = StoredCaughtPokemon.fetchRequest()
        var predicates = [NSPredicate(format: "\(#keyPath(StoredCaughtPokemon.i_gameIndex)) == %d", game.databaseIndex)]

        if let pokemonName {
            predicates.append(.init(format: "\(#keyPath(StoredCaughtPokemon.z_pokemonName)) == %@", pokemonName))
        }
        if let formName {
            predicates.append(.init(format: "\(#keyPath(StoredCaughtPokemon.z_formName)) == %@", formName))
        }
        if let index {
            predicates.append(.init(format: "\(#keyPath(StoredCaughtPokemon.z_index)) == %d", index))
        }

        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(StoredCaughtPokemon.i_gameIndex), ascending: true),
            NSSortDescriptor(key: #keyPath(StoredCaughtPokemon.z_index), ascending: true),
            NSSortDescriptor(key: #keyPath(StoredCaughtPokemon.z_formName), ascending: true)
        ]
        return request
    }

}
