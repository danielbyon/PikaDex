//
//  BattleAssistantTypeEffectiveness.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/29/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct BattleAssistantTypeEffectiveness: View {

    private let viewModel: ViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16.0) {
            if !viewModel.recommended.isEmpty {
                BattleAssistantTypeEffectivenessSection(title: "Recommended", types: viewModel.recommended)
            }
            if !viewModel.notRecommended.isEmpty {
                BattleAssistantTypeEffectivenessSection(title: "Not Recommended", types: viewModel.notRecommended)
            }
            if !viewModel.doNotUse.isEmpty {
                BattleAssistantTypeEffectivenessSection(title: "Do Not Use", types: viewModel.doNotUse)
            }
        }
    }

    init(primaryType: PokemonType, secondaryType: PokemonType?, game: Game) {
        viewModel = .init(primaryType: primaryType, secondaryType: secondaryType, game: game)
    }

}

struct BattleAssistantTypeEffectiveness_Previews: PreviewProvider {
    static var previews: some View {
        BattleAssistantTypeEffectiveness(primaryType: .fire, secondaryType: .flying, game: .sword)
    }
}

private struct BattleAssistantTypeEffectivenessSection: View {

    let title: String
    let types: [CellViewModel]

    var body: some View {
        VStack(alignment: .leading, spacing: 16.0) {
            Text(title)
                .monospacedBody()
            VStack(alignment: .leading, spacing: 8.0) {
                ForEach(types) { viewModel in
                    PokemonTypeEffectivenessCell(type: viewModel.type, value: viewModel.value, equalWidths: false, isSmall: false)
                }
            }
        }
    }

}

private struct ViewModel {

    let recommended: [CellViewModel]
    let notRecommended: [CellViewModel]
    let doNotUse: [CellViewModel]

    init(primaryType: PokemonType, secondaryType: PokemonType?, game: Game) {
        let typeEffectiveness = TypeEffectiveness(primary: primaryType, secondary: secondaryType)

        var recommended: [CellViewModel] = []
        var notRecommended: [CellViewModel] = []
        var doNotUse: [CellViewModel] = []
        PokemonType.allCases.sorted().forEach { type in
            let effectiveness = typeEffectiveness.defense(for: type, generation: game.generation)
            if effectiveness > 1 {
                recommended.append(CellViewModel(type: type, value: effectiveness))
            } else if effectiveness == 0 {
                doNotUse.append(CellViewModel(type: type, value: effectiveness))
            } else if effectiveness < 1 {
                notRecommended.append(CellViewModel(type: type, value: effectiveness))
            }
        }

        self.recommended = recommended
        self.notRecommended = notRecommended
        self.doNotUse = doNotUse
    }

}

private struct CellViewModel {

    let type: PokemonType
    let value: Double

}

extension CellViewModel: Identifiable {

    var id: String { type.rawValue + "\(value)" }

}
