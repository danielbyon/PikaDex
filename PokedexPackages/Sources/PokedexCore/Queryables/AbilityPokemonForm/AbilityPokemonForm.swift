//
//  AbilityPokemonForm.swift
//  
//
//  Created by Daniel Byon on 9/28/22.
//

import Foundation

public struct AbilityPokemonForm: Queryable {

    public typealias Filter = AbilityPokemonFormFilter

    public let name: String
    public let pokemonName: String
    public let game: Game
    public let primaryType: PokemonType
    public let secondaryType: PokemonType?
    public let spriteName: String
    public let pokedexNumbers: PokedexNumbers

    public init(result: StoredPokemonForm) {
        name = result.name
        pokemonName = result.pokemon.name
        game = result.game
        primaryType = result.primaryType
        secondaryType = result.secondaryType
        spriteName = result.spriteName
        pokedexNumbers = .init(pokedexNumbers: result.pokemon.pokedexNumbers)
    }

}

extension AbilityPokemonForm: Codable { }

extension AbilityPokemonForm: Hashable { }
