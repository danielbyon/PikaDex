//
//  BattleAssistantTypeEffectivenessViewModel.swift
//  
//
//  Created by Daniel Byon on 10/26/22.
//

import PokedexCore
import SwiftUI

final class BattleAssistantTypeEffectivenessViewModel {

    let recommended: [CellViewModel]
    let notRecommended: [CellViewModel]
    let doNotUse: [CellViewModel]

    struct CellViewModel {
        let type: PokemonType
        let value: Double
    }

    init(
        primaryType: PokemonType,
        secondaryType: PokemonType?,
        game: Game
    ) {
        let typeEffectiveness = TypeEffectiveness(primary: primaryType, secondary: secondaryType)

        var recommended: [CellViewModel] = []
        var notRecommended: [CellViewModel] = []
        var doNotUse: [CellViewModel] = []
        PokemonType.allCases
            .sorted()
            .forEach { type in
                let effectiveness = typeEffectiveness.defense(for: type, generation: game.generation)
                if effectiveness > 1 {
                    recommended.append(.init(type: type, value: effectiveness))
                } else if effectiveness == 0 {
                    doNotUse.append(.init(type: type, value: effectiveness))
                } else if effectiveness < 1 {
                    notRecommended.append(.init(type: type, value: effectiveness))
                }
            }

        self.recommended = recommended
        self.notRecommended = notRecommended
        self.doNotUse = doNotUse
    }

}

extension BattleAssistantTypeEffectivenessViewModel.CellViewModel: Identifiable {

    var id: String { type.rawValue + String(value) }

}
