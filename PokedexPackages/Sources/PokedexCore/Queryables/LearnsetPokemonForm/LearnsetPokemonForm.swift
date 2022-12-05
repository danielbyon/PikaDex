//
//  LearnsetPokemonForm.swift
//  
//
//  Created by Daniel Byon on 10/3/22.
//

import Foundation

public struct LearnsetPokemonForm {

    public let name: String
    public let formName: String
    public let index: Int
    public let formIndex: Int
    public let primaryType: PokemonType
    public let secondaryType: PokemonType?
    public let game: Game
    public let spriteName: String
    public let pokedexNumbers: PokedexNumbers

    public init(result: StoredPokemonForm) {
        self.name = result.pokemon.name
        self.formName = result.name
        self.index = result.index
        self.formIndex = result.formIndex
        self.primaryType = result.primaryType
        self.secondaryType = result.secondaryType
        self.game = result.game
        self.spriteName = result.spriteName
        self.pokedexNumbers = .init(pokedexNumbers: result.pokemon.pokedexNumbers)
    }

}

extension LearnsetPokemonForm: Codable { }

extension LearnsetPokemonForm: Hashable { }
