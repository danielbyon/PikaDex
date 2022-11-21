//
//  BattleAssistantViewFactory.swift
//  
//
//  Created by Daniel Byon on 10/26/22.
//

import PokedexUI
import SwiftUI

public protocol BattleAssistantViewFactory {

    associatedtype LearnsetCellView: View
    associatedtype PokemonAbilitiesView: View
    associatedtype PokemonTypeEffectivenessCellView: View

    func makeLearnsetCell(
        move: Move,
        detailText: String?,
        game: Game
    ) -> LearnsetCellView

    func makePokemonAbilities(form: PokemonDetailForm, pokedex: Pokedex) -> PokemonAbilitiesView

    func makePokemonTypeEffectivenessCell(
        type: PokemonType,
        value: Double,
        equalWidths: Bool,
        isSmall: Bool
    ) -> PokemonTypeEffectivenessCellView

}

struct MockBattleAssistantViewFactory: BattleAssistantViewFactory {

    func makeLearnsetCell(
        move: Move,
        detailText: String?,
        game: Game
    ) -> some View {
        EmptyView()
    }

    func makePokemonAbilities(form: PokemonDetailForm, pokedex: Pokedex) -> some View {
        EmptyView()
    }

    func makePokemonTypeEffectivenessCell(
        type: PokemonType,
        value: Double,
        equalWidths: Bool,
        isSmall: Bool
    ) -> some View {
        EmptyView()
    }

}
