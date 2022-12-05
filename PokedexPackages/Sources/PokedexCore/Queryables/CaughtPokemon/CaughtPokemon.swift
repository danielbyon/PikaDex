//
//  CaughtPokemon.swift
//  
//
//  Created by Daniel Byon on 11/4/22.
//

import CoreData
import Foundation

public struct CaughtPokemon: Queryable {

    public typealias Filter = CaughtPokemonFilter

    public let pokemonName: String
    public let formName: String
    public let index: Int
    public let game: Game

    public init(result: Filter.ResultType) {
        pokemonName = result.pokemonName
        formName = result.formName
        index = result.index
        game = result.game
    }

    public init(pokemon: Pokemon) {
        pokemonName = pokemon.name
        formName = pokemon.name // TODO: Do we support forms?
        index = pokemon.index
        game = pokemon.game
    }

    public init(pokemonDetail: PokemonDetail) {
        pokemonName = pokemonDetail.name
        formName = pokemonDetail.name // TODO: Do we support forms?
        index = pokemonDetail.index
        game = pokemonDetail.game
    }

}

extension CaughtPokemon: Codable { }

extension CaughtPokemon: Hashable { }

extension CaughtPokemon: Persistable {

    public func makeModelObject(context: NSManagedObjectContext) -> StoredCaughtPokemon {
        let object = StoredCaughtPokemon(context: context)
        object.pokemonName = pokemonName
        object.formName = formName
        object.index = index
        object.game = game
        return object
    }

}
