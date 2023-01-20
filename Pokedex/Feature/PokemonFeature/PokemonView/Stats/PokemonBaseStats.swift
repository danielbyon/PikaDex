//
//  PokemonBaseStats.swift
//  
//
//  Created by Daniel Byon on 10/16/22.
//

import PokedexUI
import SwiftUI

struct PokemonBaseStats: View {

    let stats: Stats

    private var viewModels: [BaseStatViewModel] {
        BaseStatViewModel.makeViewModels(from: stats)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(viewModels) { stat in
                HStack {
                    ZStack(alignment: .topTrailing) {
                        Text(stat.name + ":")
                        Text("   ")
                    }
                    .monospacedBody()

                    ZStack(alignment: .topTrailing) {
                        Text("\(stat.value)")
                        Text("   ")
                    }
                    .monospacedBody()

                    Gauge(value: stat.fraction) {
                        EmptyView()
                    }
                    .gaugeStyle(.linearCapacity)
                    .tint(stat.color)
                }
            }
            Text("Total: \(stats.total)")
                .monospacedBody()
        }
    }

}

struct PokemonBaseStats_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PokemonBaseStats(stats: .init(
                attack: 120,
                defense: 80,
                hp: 140,
                specialAttack: 75,
                specialDefense: 78,
                speed: 94
            ))
        }
    }
}

private struct BaseStatViewModel: Identifiable {

    let name: String
    let value: Int
    let fraction: Double
    let color: Color

    var id: String {
        return name
    }

    static func makeViewModels(from stats: Stats) -> [BaseStatViewModel] {
        [
            BaseStatViewModel(name: " HP", value: stats.hp, fraction: stats.hpFraction, color: Color(Stats.hpColor)),
            BaseStatViewModel(name: "ATK", value: stats.attack, fraction: stats.attackFraction, color: Color(Stats.attackColor)),
            BaseStatViewModel(name: "DEF", value: stats.defense, fraction: stats.defenseFraction, color: Color(Stats.defenseColor)),
            BaseStatViewModel(name: "SPA", value: stats.specialAttack, fraction: stats.specialAttackFraction, color: Color(Stats.specialAttackColor)),
            BaseStatViewModel(name: "SDF", value: stats.specialDefense, fraction: stats.specialDefenseFraction, color: Color(Stats.specialDefenseColor)),
            BaseStatViewModel(name: "SPD", value: stats.speed, fraction: stats.speedFraction, color: Color(Stats.speedColor))
        ]
    }

}

// MARK: - StoredStats
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

    var total: Int { hp + attack + defense + specialAttack + specialDefense + speed }

}
