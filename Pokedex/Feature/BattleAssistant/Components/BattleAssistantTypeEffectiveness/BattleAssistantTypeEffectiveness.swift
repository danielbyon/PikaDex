//
//  BattleAssistantTypeEffectiveness.swift
//  
//
//  Created by Daniel Byon on 10/26/22.
//

import PokedexUI
import SwiftUI

struct BattleAssistantTypeEffectiveness: View {

    let viewModel: BattleAssistantTypeEffectivenessViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16.0) {
            if !viewModel.recommended.isEmpty {
                BattleAssistantTypeEffectivenessSection(
                    title: "Recommended",
                    types: viewModel.recommended
                )
            }
            if !viewModel.notRecommended.isEmpty {
                BattleAssistantTypeEffectivenessSection(
                    title: "Not Recommended",
                    types: viewModel.notRecommended
                )
            }
            if !viewModel.doNotUse.isEmpty {
                BattleAssistantTypeEffectivenessSection(
                    title: "Do Not Use",
                    types: viewModel.doNotUse
                )
            }
        }
    }

    init(
        primaryType: PokemonType,
        secondaryType: PokemonType?,
        game: Game
    ) {
        viewModel = .init(
            primaryType: primaryType,
            secondaryType: secondaryType,
            game: game
        )
    }

}

struct BattleAssistantTypeEffectiveness_Previews: PreviewProvider {
    static var previews: some View {
        BattleAssistantTypeEffectiveness(
            primaryType: .fire,
            secondaryType: .flying,
            game: .sword
        )
    }
}
