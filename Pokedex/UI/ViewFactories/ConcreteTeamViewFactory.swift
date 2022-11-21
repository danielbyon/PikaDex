//
//  ConcreteTeamViewFactory.swift
//  Pokedex
//
//  Created by Daniel Byon on 10/30/22.
//  Copyright © 2022 Daniel Byon. All rights reserved.
//

import AbilityFeature
import BattleAssistantFeature
import ItemFeature
import MoveFeature
import NatureFeature
import PokedexUI
import PokemonFeature
import TeamFeature
import SwiftUI

struct ConcreteTeamViewFactory: TeamViewFactory {

    func makeAbilityCell(ability: Ability) -> some View {
        AbilityFeature.AbilityCell(ability: ability)
    }

    func makeAbilityView(ability: Ability, game: Game, pokedex: Pokedex) -> some View {
        AbilityFeature.AbilityView(ability: ability, game: game, pokedex: pokedex)
    }

    func makeItemCell(item: Item) -> some View {
        ItemFeature.ItemCell(item: item)
    }

    func makeLearnsetCell(move: Move, detailText: String?, game: Game) -> some View {
        PokemonFeature.LearnsetCell(move: move, detailText: detailText, game: game)
    }

    func makeMoveView(move: Move) -> some View {
        MoveFeature.MoveView(move: move, viewFactory: ConcreteMoveViewFactory())
    }

    func makeNatureCell(nature: Nature) -> some View {
        NatureFeature.NatureCell(viewModel: .init(nature: nature))
    }

    func makePokemonView(pokemonDetailForm: PokemonDetailForm, pokedex: Pokedex) -> some View {
        PokemonFeature.PokemonView(pokemonDetailForm: pokemonDetailForm, pokedex: pokedex)
    }

    func makeSelectPokemonFormView(game: Game) -> some View {
        BattleAssistantFeature.SelectPokemonForm(game: game)
    }

}
