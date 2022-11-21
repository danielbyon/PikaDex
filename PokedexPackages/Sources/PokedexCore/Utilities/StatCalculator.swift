//
//  StatCalculator.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/21/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

// hp
// floor((2 * B + I + E) * L / 100 + L + 10)

// stats
//Stat = floor(floor((2 * B + I + E) * L / 100 + 5) * N)

public enum StatCalculator {

    public static func calculateStat(statType: StatType, baseValue: Int, iv: Int, ev: Int, level: Int, nature: Nature, game: Game) -> Int {
        if case .hp = statType {
            var value = Double(((2 * baseValue) + iv + EValue(forEV: ev)) * level) / 100.0
            value += Double(level) + 10.0
            return Int(value.rounded(.down))
        } else {
            return Int(floor(floor(Double((2 * baseValue + iv + EValue(forEV: ev)) * level) / 100.0 + 5.0) * nature.factor(forStatType: statType)))
        }
    }

    public static func calculatePreAdvanceHPIV(attackIV: Int, defenseIV: Int, speedIV: Int, specialIV: Int) -> Int {
        var value = 0
        if attackIV.isOdd {
            value += 8
        }
        if defenseIV.isOdd {
            value += 4
        }
        if speedIV.isOdd {
            value += 2
        }
        if specialIV.isOdd {
            value += 1
        }
        return value
    }

    private static func EValue(forEV ev: Int) -> Int {
        Int((Double(ev) / 4.0).rounded(.down))
    }

}

private extension Nature {

    func factor(forStatType statType: StatType) -> Double {
        if increasedStat == statType {
            return 1.1
        } else if decreasedStat == statType {
            return 0.9
        } else {
            return 1.0
        }
    }

}
