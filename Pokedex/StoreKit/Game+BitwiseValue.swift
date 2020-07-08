//
//  Game+BitwiseValue.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/26/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

extension Game {

    var bitwiseValue: Int64 {
        var value: Int64 = 0
        switch self {
        case .red:
            value = 1 << 0
        case .blue:
            value = 1 << 1
        case .yellow:
            value = 1 << 2
        case .gold:
            value = 1 << 3
        case .silver:
            value = 1 << 4
        case .crystal:
            value = 1 << 5
        case .ruby:
            value = 1 << 6
        case .sapphire:
            value = 1 << 7
        case .emerald:
            value = 1 << 8
        case .fireRed:
            value = 1 << 9
        case .leafGreen:
            value = 1 << 10
        case .diamond:
            value = 1 << 11
        case .pearl:
            value = 1 << 12
        case .platinum:
            value = 1 << 13
        case .heartGold:
            value = 1 << 14
        case .soulSilver:
            value = 1 << 15
        case .black:
            value = 1 << 16
        case .white:
            value = 1 << 17
        case .black2:
            value = 1 << 18
        case .white2:
            value = 1 << 19
        case .x:
            value = 1 << 20
        case .y:
            value = 1 << 21
        case .omegaRuby:
            value = 1 << 22
        case .alphaSapphire:
            value = 1 << 23
        case .sun:
            value = 1 << 24
        case .moon:
            value = 1 << 25
        case .ultraSun:
            value = 1 << 26
        case .ultraMoon:
            value = 1 << 27
        case .letsGoPikachu:
            value = 1 << 28
        case .letsGoEevee:
            value = 1 << 29
        case .sword:
            value = 1 << 30
        case .shield:
            value = 1 << 31
        }
        return value
    }

}
