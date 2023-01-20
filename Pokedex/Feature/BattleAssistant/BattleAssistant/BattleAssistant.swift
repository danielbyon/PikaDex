//
//  BattleAssistant.swift
//  
//
//  Created by Daniel Byon on 10/23/22.
//

import PokedexUI
import SwiftUI

public struct BattleAssistant: View {

    let game: Game

    @StateObject private var viewModel = BattleAssistantViewModel()

    public var body: some View {
        List {
            Section {
                NavigationLink(value: Route.battleAssistant(.selectPokemon(
                    game,
                    onSelect: {
                        viewModel.pokemonForm = $0
                    }
                ))) {
                    if let pokemonForm = viewModel.pokemonForm {
                        PokemonCell(pokemonForm: pokemonForm)
                    } else {
                        Text("Select Pokémon")
                            .monospacedBody()
                    }
                }

                if viewModel.pokemonForm != nil {
                    LevelSlider(level: $viewModel.level)
                }
            } header: {
                SectionHeader("Pokémon")
            }

            if let pokemonForm = viewModel.pokemonForm {
                BattleAssistantDetail(
                    pokemonForm: pokemonForm,
                    level: Int(viewModel.level)
                )
            } else {
                Text("Select a Pokémon and level to view helpful info when battling.")
                    .monospacedBody()
            }
        }
        .listStyle(.grouped)
        .navigationTitle("Battle Assistant")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                HomeButton()
            }
        }
        .onAppear {
            viewModel.onAppear(game: game)
        }
    }

}

struct BattleAssistant_Previews: PreviewProvider {
    static var previews: some View {
        BattleAssistant(game: .sword)
    }
}
