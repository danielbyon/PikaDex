//
//  BattleAssistant.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/17/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI

struct BattleAssistant: View {

    @EnvironmentObject var settings: AppSettings
    @StateObject private var viewModel: BattleAssistantViewModel = .init()
    @State private var isShowingSelectPokemon = false

    private var movesFooter: String {
        """
        This list may not include special moves that a Trainer or Gym Leader's Pokémon could use.
        """
    }
    private var padding: CGFloat { 4.0 }

    var body: some View {
        VStack {
            NavigationLink(destination: SelectPokemon(game: settings.currentGame, onSelect: { pokemon in
                self.viewModel.pokemon = pokemon
            }), isActive: $isShowingSelectPokemon) {
                EmptyView()
            }
            .hidden()
            
            List {
                Section(header: SectionHeader("Pokémon")) {
                    Button {
                        self.isShowingSelectPokemon.toggle()
                    } label: {
                        if let pokemon = viewModel.pokemon {
                            PokemonCell(pokemon: pokemon, game: settings.currentGame)
                        } else {
                            Text("Select Pokémon")
                                .monospacedBody()
                        }
                    }
                    .foregroundColor(.primary)

                    if viewModel.pokemon != nil {
                        BattleAssistantLevelSlider(level: $viewModel.level)
                    }
                }

                if let pokemon = viewModel.pokemon {
                    Section {
                        NavigationLink(destination: PokemonDetail(pokemon: pokemon, game: settings.currentGame)) {
                            Text("View Pokémon details")
                                .monospacedBody()
                        }
                    }

                    BattleAssistantInfo(pokemon: pokemon, level: Int(viewModel.level))
                } else {
                    Text("Select a Pokémon and level to view helpful info when battling.")
                        .monospacedBody()
                }
            }
            .listStyle(GroupedListStyle())
        }
        .navigationTitle("Battle Assistant")
    }
}

struct BattleAssistant_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BattleAssistant()
                .injectDependencies()
        }
    }
}
