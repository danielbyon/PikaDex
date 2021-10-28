//
//  Pocket+Strings.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/30/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

extension Pocket {

    func title(forGame game: Game) -> String {
        switch game {
        case .red, .blue, .yellow:
            assert(self == .items)
            return "Items"
        case .gold, .silver, .crystal:
            switch self {
            case .items:
                return "Items"
            case .pokeBalls:
                return "Balls"
            case .key:
                return "Key Items"
            case .machines:
                return "TM/HM"
            default:
                return "Items"
            }
        case .ruby, .sapphire, .emerald:
            switch self {
            case .berry:
                return "Berries"
            case .items:
                return "Items"
            case .key:
                return "Key Items"
            case .machines:
                return "TMs & HMs"
            case .pokeBalls:
                return "Poké Balls"
            default:
                return "Items"
            }
        case .fireRed, .leafGreen:
            switch self {
            case .items:
                return "Items"
            case .key:
                return "Key Items"
            case .pokeBalls:
                return "Poké Balls"
            default:
                return "Items"
            }
        case .diamond, .pearl, .platinum, .heartGold, .soulSilver:
            switch self {
            case .battle:
                return "Battle Items"
            case .berry:
                return "Berries"
            case .items:
                return "Items"
            case .key:
                return "Key Items"
            case .machines:
                return "TMs & HMs"
            case .medicine:
                return "Medicine"
            case .pokeBalls:
                return "Poké Balls"
            default:
                return "Items"
            }
        case .black, .white, .black2, .white2:
            switch self {
            case .berry:
                return "Berries"
            case .items:
                return "Items"
            case .key:
                return "Key Items"
            case .machines:
                return "TMs & HMs"
            case .medicine:
                return "Medicine"
            default:
                return "Items"
            }
        case .x, .y, .omegaRuby, .alphaSapphire:
            switch self {
            case .berry:
                return "Berries"
            case .items:
                return "Items"
            case .key:
                return "Key Items"
            case .machines:
                return "TMs & HMs"
            case .medicine:
                return "Medicine"
            default:
                return "Items"
            }
        case .sun, .moon, .ultraSun, .ultraMoon, .letsGoPikachu, .letsGoEevee:
            switch self {
            case .berry:
                return "Berries"
            case .items:
                return "Items"
            case .key:
                return "Key Items"
            case .machines:
                return "TMs"
            case .medicine:
                return "Medicine"
            case .zCrystals:
                return "Z-Crystals"
            default:
                return "Items"
            }
        case .sword, .shield, .national:
            switch self {
            case .battle:
                return "Battle Items"
            case .berry:
                return "Berries"
            case .ingredients:
                return "Ingredients"
            case .key:
                return "Key Items"
            case .machines:
                return "TMs"
            case .medicine:
                return "Medicine"
            case .otherItems:
                return "Other Items"
            case .pokeBalls:
                return "Poké Balls"
            case .treasures:
                return "Treasures"
            default:
                return "Items"
            }
        }
    }

}
