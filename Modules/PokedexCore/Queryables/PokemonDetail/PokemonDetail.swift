//
//  PokemonDetail.swift
//  
//
//  Created by Daniel Byon on 9/21/22.
//

import Foundation

public struct PokemonDetail: Queryable {

    public typealias Filter = PokemonDetailFilter

    public let name: String
    public let index: Int
    public let game: Game
    public let generationIntroduced: Generation
    /// - Important: MUST have at least one form
    public let forms: [PokemonDetailForm]
    public let pokedexNumbers: PokedexNumbers
    public let catchRate: Int
    public let eggGroups: [EggGroup]
    public let levelingRate: LevelingRate
    public let maleRatio: Double?
    public let bulbapediaURL: URL
    public let pokemonDBURL: URL

    public var mainForm: PokemonDetailForm { forms[0] }

    public var hasAlternateForms: Bool { forms.count > 1 }

    public var femaleRatio: Double? { maleRatio != nil ? 100.0 - maleRatio! : nil }

    public init(result: StoredPokemon) {
        self.name = result.name
        self.index = result.index
        self.game = result.game
        self.generationIntroduced = result.generationIntroduced
        self.forms = result.forms.map(PokemonDetailForm.init)
        self.pokedexNumbers = PokedexNumbers(pokedexNumbers: result.pokedexNumbers)
        self.catchRate = result.catchRate
        self.eggGroups = result.eggGroups
        self.levelingRate = result.levelingRate
        self.maleRatio = result.maleRatio
        self.bulbapediaURL = result.bulbapediaURL
        self.pokemonDBURL = result.pokemonDBURL
    }

    public init(
        name: String,
        index: Int,
        game: Game,
        generationIntroduced: Generation,
        forms: [PokemonDetailForm],
        pokedexNumbers: PokedexNumbers,
        catchRate: Int,
        eggGroups: [EggGroup],
        levelingRate: LevelingRate,
        maleRatio: Double? = nil,
        bulbapediaURL: URL,
        pokemonDBURL: URL
    ) {
        self.name = name
        self.index = index
        self.game = game
        self.generationIntroduced = generationIntroduced
        self.forms = forms
        self.pokedexNumbers = pokedexNumbers
        self.catchRate = catchRate
        self.eggGroups = eggGroups
        self.levelingRate = levelingRate
        self.maleRatio = maleRatio
        self.bulbapediaURL = bulbapediaURL
        self.pokemonDBURL = pokemonDBURL
    }

    public func number(for pokedex: Pokedex) -> Int {
        pokedexNumbers.number(for: pokedex)
    }

    public func pokedexNumberString(for pokedex: Pokedex) -> String {
        PokedexNumberFormat.pokemonIndex.format(number(for: pokedex))
    }

}

extension PokemonDetail: Codable { }

extension PokemonDetail: Equatable { }

extension PokemonDetail: Hashable { }
