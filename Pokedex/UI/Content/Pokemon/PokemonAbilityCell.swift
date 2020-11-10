//
//  PokemonAbilityCell.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/20/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI

struct PokemonAbilityCell: View {

    let ability: Ability
    let game: Game
    var isHidden = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            HStack(alignment: .firstTextBaseline, spacing: 4.0) {
                Text(ability.name)
                    .monospacedBody()
                if isHidden {
                    Text(" (hidden)")
                        .monospacedCaption()
                }
            }
            if let description = ability.description(forGame: game) {
                Text(description)
                    .monospacedCaption()
            }
        }
        .contentShape(Rectangle())
        .multilineTextAlignment(.leading)
        .padding(.vertical, 4.0)
    }

}

struct PokemonAbility_Previews: PreviewProvider {
    static var previews: some View {
        PokemonAbilityCell(ability: .generateBlaze(), game: .sword)
            .injectDependencies()
    }
}
