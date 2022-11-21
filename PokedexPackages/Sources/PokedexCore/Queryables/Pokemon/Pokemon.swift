//
//  Pokemon.swift
//  Pokedex
//
//  Created by Daniel Byon on 10/19/21.
//  Copyright © 2021 Daniel Byon. All rights reserved.
//

import Foundation

public struct Pokemon: Queryable {

    public typealias Filter = PokemonFilter

    public let game: Game
    public let generationIntroduced: Generation
    public let index: Int
    public let name: String
    public let primaryType: PokemonType
    public let secondaryType: PokemonType?
    public let spriteName: String
    public let pokedexNumbers: PokedexNumbers

    public init(result: StoredPokemon) {
        self.game = result.game
        self.generationIntroduced = result.generationIntroduced
        self.index = result.index
        self.name = result.name
        self.primaryType = result.defaultForm.primaryType
        self.secondaryType = result.defaultForm.secondaryType
        self.spriteName = result.defaultForm.spriteName
        self.pokedexNumbers = PokedexNumbers(pokedexNumbers: result.pokedexNumbers)
    }

    public init(
        game: Game,
        generationIntroduced: Generation,
        index: Int,
        name: String,
        primaryType: PokemonType,
        secondaryType: PokemonType?,
        spriteName: String,
        pokedexNumbers: PokedexNumbers
    ) {
        self.game = game
        self.generationIntroduced = generationIntroduced
        self.index = index
        self.name = name
        self.primaryType = primaryType
        self.secondaryType = secondaryType
        self.spriteName = spriteName
        self.pokedexNumbers = pokedexNumbers
    }

    public func number(for pokedex: Pokedex) -> Int {
        pokedexNumbers.number(for: pokedex)
    }

}

extension Pokemon: Codable { }

extension Pokemon: Hashable { }
