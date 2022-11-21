//
//  BattleAssistant.swift
//  
//
//  Created by Daniel Byon on 10/23/22.
//

import PokedexUI
import SwiftUI

public struct BattleAssistant<ViewFactory: BattleAssistantViewFactory>: View {

    let game: Game
    let viewFactory: ViewFactory

    @StateObject private var viewModel = BattleAssistantViewModel()

    public var body: some View {
        List {
            Section {
                NavigationLink {
                    SelectPokemonForm(game: game)
                        .onSelectPokemonForm { pokemonForm in
                            viewModel.pokemonForm = pokemonForm
                        }
                } label: {
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
                    level: Int(viewModel.level),
                    viewFactory: viewFactory
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

    public init(
        game: Game,
        viewFactory: ViewFactory
    ) {
        self.game = game
        self.viewFactory = viewFactory
    }

}

struct BattleAssistant_Previews: PreviewProvider {
    static var previews: some View {
        BattleAssistant(
            game: .sword,
            viewFactory: MockBattleAssistantViewFactory()
        )
    }
}
