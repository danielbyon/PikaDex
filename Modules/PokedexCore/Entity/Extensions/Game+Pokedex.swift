//
//  Game+Pokedex.swift
//  Pokedex
//
//  Created by Daniel Byon on 9/16/22.
//  Copyright © 2022 Daniel Byon. All rights reserved.
//

import Foundation

extension Game {

    public var pokedexes: [Pokedex] {
        var retVal: [Pokedex] = [.national]
        switch self {
        case .red, .blue, .yellow, .fireRed, .leafGreen:
            retVal.append(.kanto)
        case .gold, .silver, .crystal:
            retVal.append(.johto)
        case .ruby, .sapphire, .emerald:
            retVal.append(.hoenn)
        case .diamond, .pearl, .platinum, .brilliantDiamond, .shiningPearl:
            retVal.append(.sinnoh)
        case .heartGold, .soulSilver:
            retVal.append(.newJohto)
        case .black, .white:
            retVal.append(.unova)
        case .black2, .white2:
            retVal.append(.newUnova)
        case .x, .y:
            retVal.append(.centralKalos)
            retVal.append(.coastalKalos)
            retVal.append(.mountainKalos)
        case .omegaRuby, .alphaSapphire:
            retVal.append(.newHoenn)
        case .sun, .moon:
            retVal.append(.alola)
            retVal.append(.melemele)
            retVal.append(.akala)
            retVal.append(.ulaula)
            retVal.append(.poni)
        case .ultraSun, .ultraMoon:
            retVal.append(.ultraAlola)
            retVal.append(.ultraMelemele)
            retVal.append(.ultraAkala)
            retVal.append(.ultraUlaula)
            retVal.append(.ultraPoni)
        case .letsGoPikachu, .letsGoEevee:
            retVal.append(.letsGoKanto)
        case .sword, .shield:
            retVal.append(.galar)
            retVal.append(.isleOfArmor)
            retVal.append(.crownTundra)
        case .legendsArceus:
            retVal.append(.hisui)
        case .scarlet, .violet:
            retVal.append(.paldea)
            retVal.append(.kitakami)
            retVal.append(.blueberry)
        case .national:
            retVal.append(.kanto)
            retVal.append(.johto)
            retVal.append(.hoenn)
            retVal.append(.sinnoh)
            retVal.append(.unova)
            retVal.append(.centralKalos)
            retVal.append(.coastalKalos)
            retVal.append(.mountainKalos)
            retVal.append(.alola)
            retVal.append(.melemele)
            retVal.append(.akala)
            retVal.append(.ulaula)
            retVal.append(.poni)
            retVal.append(.galar)
            retVal.append(.isleOfArmor)
            retVal.append(.crownTundra)
            retVal.append(.hisui)
            retVal.append(.paldea)
            retVal.append(.kitakami)
            retVal.append(.blueberry)
        }
        return retVal
    }

}
