//
//  ConcreteBattleAssistantViewFactory.swift
//  Pokedex
//
//  Created by Daniel Byon on 10/26/22.
//  Copyright © 2022 Daniel Byon. All rights reserved.
//

import BattleAssistantFeature
import PokemonFeature
import SwiftUI

struct ConcreteBattleAssistantViewFactory: BattleAssistantViewFactory {

    func makeLearnsetCell(
        move: Move,
        detailText: String?,
        game: Game
    ) -> some View {
        LearnsetCell(move: move, detailText: detailText, game: game)
    }

    func makePokemonAbilities(form: PokemonDetailForm, pokedex: Pokedex) -> some View {
        PokemonAbilities(form: form, pokedex: pokedex)
    }

    func makePokemonTypeEffectivenessCell(
        type: PokemonType,
        value: Double,
        equalWidths: Bool,
        isSmall: Bool
    ) -> some View {
        PokemonTypeEffectivenessCell(
            type: type,
            value: value,
            equalWidths: equalWidths,
            isSmall: isSmall
        )
    }

}
