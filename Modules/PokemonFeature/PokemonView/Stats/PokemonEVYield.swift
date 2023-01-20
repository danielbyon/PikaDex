//
//  PokemonEVYield.swift
//  
//
//  Created by Daniel Byon on 10/16/22.
//

import PokedexUI
import SwiftUI

struct PokemonEVYield: View {

    let evYield: Stats

    var body: some View {
        HStack {
            VStack {
                EVYieldComponent(name: "HP", value: evYield.hp, color: Stats.hpColor)
                EVYieldComponent(name: "Attack", value: evYield.attack, color: Stats.attackColor)
            }
            VStack {
                EVYieldComponent(name: "Defense", value: evYield.defense, color: Stats.defenseColor)
                EVYieldComponent(name: "Sp. Atk", value: evYield.specialAttack, color: Stats.specialAttackColor)
            }
            VStack {
                EVYieldComponent(name: "Sp. Def", value: evYield.specialDefense, color: Stats.specialDefenseColor)
                EVYieldComponent(name: "Speed", value: evYield.speed, color: Stats.speedColor)
            }
        }
    }
}

struct PokemonEVYield_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PokemonEVYield(evYield: .init(
                attack: 0,
                defense: 3,
                hp: 1,
                specialAttack: 0,
                specialDefense: 0,
                speed: 2
            ))
        }
    }
}

private struct EVYieldComponent: View {

    var name: String
    var value: Int
    var color: UIColor

    private var shadowRadius: CGFloat { 2.0 }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4.0)
                .fill(Color(color))
                .opacity(0.7)
                .shadow(radius: shadowRadius)
            VStack {
                Text("\(value)")
                    .monospacedBody()
                Text(name)
                    .monospacedCaption()
            }
            .padding(.vertical, 4)
        }
    }

}
