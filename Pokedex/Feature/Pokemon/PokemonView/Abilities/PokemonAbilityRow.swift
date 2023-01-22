//
//  PokemonAbilityRow.swift
//  
//
//  Created by Daniel Byon on 9/23/22.
//

import PokedexCore
import PokedexUI
import SwiftUI

struct PokemonAbilityRow: View {

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
            if let description = ability[game] {
                Text(description)
                    .monospacedCaption()
            }
        }
        .contentShape(Rectangle())
        .multilineTextAlignment(.leading)
        .padding(.vertical, 4.0)
    }

}

struct PokemonAbilityRow_Previews: PreviewProvider {
    static var previews: some View {
        PokemonAbilityRow(
            ability: .blaze,
            game: .sword
        )
    }
}
