//
//  BattleAssistantTypeEffectiveness.swift
//  
//
//  Created by Daniel Byon on 10/26/22.
//

import PokedexUI
import SwiftUI

struct BattleAssistantTypeEffectiveness<ViewFactory: BattleAssistantViewFactory>: View {

    let viewModel: BattleAssistantTypeEffectivenessViewModel
    let viewFactory: ViewFactory

    var body: some View {
        VStack(alignment: .leading, spacing: 16.0) {
            if !viewModel.recommended.isEmpty {
                BattleAssistantTypeEffectivenessSection(
                    title: "Recommended",
                    types: viewModel.recommended,
                    viewFactory: viewFactory
                )
            }
            if !viewModel.notRecommended.isEmpty {
                BattleAssistantTypeEffectivenessSection(
                    title: "Not Recommended",
                    types: viewModel.notRecommended,
                    viewFactory: viewFactory
                )
            }
            if !viewModel.doNotUse.isEmpty {
                BattleAssistantTypeEffectivenessSection(
                    title: "Do Not Use",
                    types: viewModel.doNotUse,
                    viewFactory: viewFactory
                )
            }
        }
    }

    init(
        primaryType: PokemonType,
        secondaryType: PokemonType?,
        game: Game,
        viewFactory: ViewFactory
    ) {
        viewModel = .init(
            primaryType: primaryType,
            secondaryType: secondaryType,
            game: game
        )
        self.viewFactory = viewFactory
    }

}

struct BattleAssistantTypeEffectiveness_Previews: PreviewProvider {
    static var previews: some View {
        BattleAssistantTypeEffectiveness(
            primaryType: .fire,
            secondaryType: .flying,
            game: .sword,
            viewFactory: MockBattleAssistantViewFactory()
        )
    }
}
