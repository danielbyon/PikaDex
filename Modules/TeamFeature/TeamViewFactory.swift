//
//  TeamViewFactory.swift
//  
//
//  Created by Daniel Byon on 10/30/22.
//

import PokedexUI
import SwiftUI

public protocol TeamViewFactory {

    associatedtype AbilityCell: View
    associatedtype AbilityView: View
    associatedtype ItemCell: View
    associatedtype LearnsetCell: View
    associatedtype MoveView: View
    associatedtype NatureCell: View
    associatedtype PokemonView: View
    associatedtype SelectPokemonFormView: View

    func makeAbilityCell(ability: Ability) -> AbilityCell
    func makeAbilityView(ability: Ability, game: Game, pokedex: Pokedex) -> AbilityView
    func makeItemCell(item: Item) -> ItemCell
    func makeLearnsetCell(move: Move, detailText: String?, game: Game) -> LearnsetCell
    func makeMoveView(move: Move) -> MoveView
    func makeNatureCell(nature: Nature) -> NatureCell
    func makePokemonView(pokemonDetailForm: PokemonDetailForm, pokedex: Pokedex) -> PokemonView
    func makeSelectPokemonFormView(game: Game) -> SelectPokemonFormView

}

struct MockTeamViewFactory: TeamViewFactory {

    func makeAbilityCell(ability: Ability) -> some View {
        EmptyView()
    }

    func makeAbilityView(ability: Ability, game: Game, pokedex: Pokedex) -> some View {
        EmptyView()
    }

    func makeItemCell(item: Item) -> some View {
        EmptyView()
    }

    func makeLearnsetCell(move: Move, detailText: String?, game: Game) -> some View {
        EmptyView()
    }

    func makeMoveView(move: Move) -> some View {
        EmptyView()
    }

    func makeNatureCell(nature: Nature) -> some View {
        EmptyView()
    }

    func makePokemonView(pokemonDetailForm: PokemonDetailForm, pokedex: Pokedex) -> some View {
        EmptyView()
    }

    func makeSelectPokemonFormView(game: Game) -> some View {
        EmptyView()
    }

}
