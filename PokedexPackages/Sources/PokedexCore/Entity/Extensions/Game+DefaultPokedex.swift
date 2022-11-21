//
//  Game+DefaultPokedex.swift
//  Pokedex
//
//  Created by Daniel Byon on 9/14/22.
//  Copyright © 2022 Daniel Byon. All rights reserved.
//

import Foundation

extension Game {

    public var defaultPokedex: Pokedex {
        switch self {
        case .red, .blue, .yellow, .fireRed, .leafGreen:
            return .kanto
        case .gold, .silver, .crystal:
            return .johto
        case .ruby, .sapphire, .emerald:
            return .hoenn
        case .diamond, .pearl, .platinum, .brilliantDiamond, .shiningPearl:
            return .sinnoh
        case .heartGold, .soulSilver:
            return .newJohto
        case .black, .white:
            return .unova
        case .black2, .white2:
            return .newUnova
        case .x, .y:
            return .centralKalos
        case .omegaRuby, .alphaSapphire:
            return .newHoenn
        case .sun, .moon:
            return .alola
        case .ultraSun, .ultraMoon:
            return .ultraAlola
        case .letsGoPikachu, .letsGoEevee:
            return .letsGoKanto
        case .sword, .shield:
            return .galar
        case .legendsArceus: return .hisui
        case .national: return .national
        }
    }

}
