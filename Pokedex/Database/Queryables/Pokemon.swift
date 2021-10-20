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

    public let catchRate: Int
    public let eggGroups: [EggGroup]
    public let game: Game
    public let generationIntroduced: Generation
    public let index: Int
    public let levelingRate: LevelingRate
    public let maleRatio: Double?
    public let name: String

//    public let forms: [PokemonForm]
//    public let pokedexNumbers: PokedexNumbers

    public init(result: StoredPokemon) {
        self.catchRate = Int(result.z_catchRate)
        self.eggGroups = (result.z_eggGroups ?? _missingString)
            .components(separatedBy: ",")
            .compactMap { EggGroup(rawValue: $0) }
        self.game = Game(rawValue: result.z_game!)!
        self.generationIntroduced = Generation(rawValue: Int(result.z_generationIntroduced))!
        self.index = Int(result.z_index)
        self.levelingRate = LevelingRate(rawValue: result.z_levelingRate!)!
        self.maleRatio = result.z_maleRatio?.doubleValue
        self.name = result.z_name!
    }

}
