//
//  PokemonDetailSection.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/11/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

public enum PokemonDetailSection: String, CaseIterable, Codable, Hashable {
    case forms = "Forms"
    case pokedexEntry = "Pokedex Entry"
    case abilities = "Abilities"
    case typeEffectiveness = "Type Effectiveness"
    case moves = "Moves"
    case evolutions = "Evolutions"
    case locations = "Locations"
    case baseStats = "Base Stats"
    case evYield = "EV Yield"
    case pokedexNumbers = "Pokedex Numbers"
    case basicInfo = "Basic Info"
    case externalLinks = "Links"
}
