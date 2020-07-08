//
//  BaseStatViewModel.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/23/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI

struct BaseStatViewModel: Identifiable {

    let name: String
    let value: Int
    let fraction: Double
    let color: Color

    var id: String {
        return name
    }

    static func makeViewModels(from stats: Stats) -> [BaseStatViewModel] {
        [
            BaseStatViewModel(name: "HP", value: stats.hp, fraction: stats.hpFraction, color: Color(Stats.hpColor)),
            BaseStatViewModel(name: "ATK", value: stats.attack, fraction: stats.attackFraction, color: Color(Stats.attackColor)),
            BaseStatViewModel(name: "DEF", value: stats.defense, fraction: stats.defenseFraction, color: Color(Stats.defenseColor)),
            BaseStatViewModel(name: "SPA", value: stats.specialAttack, fraction: stats.specialAttackFraction, color: Color(Stats.specialAttackColor)),
            BaseStatViewModel(name: "SDF", value: stats.specialDefense, fraction: stats.specialDefenseFraction, color: Color(Stats.specialDefenseColor)),
            BaseStatViewModel(name: "SPD", value: stats.speed, fraction: stats.speedFraction, color: Color(Stats.speedColor)),
            BaseStatViewModel(name: "Total", value: stats.total, fraction: -1.0, color: Color(Stats.totalColor))
        ]
    }

}

// MARK: - Stats
private extension Stats {

    static let max = 255 // Max of any stat of any Pokemon of any generation

    var hpFraction: Double {
        Double(hp) / Double(Self.max)
    }

    var attackFraction: Double {
        Double(attack) / Double(Self.max)
    }

    var defenseFraction: Double {
        Double(defense) / Double(Self.max)
    }

    var specialAttackFraction: Double {
        Double(specialAttack) / Double(Self.max)
    }

    var specialDefenseFraction: Double {
        Double(specialDefense) / Double(Self.max)
    }

    var speedFraction: Double {
        Double(speed) / Double(Self.max)
    }

}
