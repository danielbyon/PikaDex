//
//  PokemonEVYield.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/22/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI

struct PokemonEVYield: View {

    let hp: Int
    let attack: Int
    let defense: Int
    let specialAttack: Int
    let specialDefense: Int
    let speed: Int

    var body: some View {
        HStack {
            VStack {
                EVYieldComponent(name: "HP", value: hp, color: Stats.hpColor)
                EVYieldComponent(name: "Attack", value: attack, color: Stats.attackColor)
            }
            VStack {
                EVYieldComponent(name: "Defense", value: defense, color: Stats.defenseColor)
                EVYieldComponent(name: "Sp. Atk", value: specialAttack, color: Stats.specialAttackColor)
            }
            VStack {
                EVYieldComponent(name: "Sp. Def", value: specialDefense, color: Stats.specialDefenseColor)
                EVYieldComponent(name: "Speed", value: speed, color: Stats.speedColor)
            }
        }
    }
}

struct PokemonEVYield_Previews: PreviewProvider {
    static var previews: some View {
        PokemonEVYield(hp: 1, attack: 3, defense: 0, specialAttack: 0, specialDefense: 0, speed: 2)
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
