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
        Form {
            Section(header: SectionHeader("Pokémon")) {
                NavigationLink(destination: SelectPokemon(game: settings.currentGame, onSelect: { pokemon in
                    self.viewModel.pokemon = pokemon
                    self.isShowingSelectPokemon = false
                }), isActive: $isShowingSelectPokemon) {
                    if let pokemon = viewModel.pokemon {
                        PokemonCell(pokemon: pokemon, game: settings.currentGame)
                            .onTapGesture {
                                self.isShowingSelectPokemon.toggle()
                        }
                    } else {
                        Text("Select Pokémon")
                            .monospacedBody()
                            .onTapGesture {
                                self.isShowingSelectPokemon.toggle()
                        }
                    }
                }
                if viewModel.pokemon != nil {
                    Picker("Level", selection: $viewModel.level) {
                        ForEach(1...100, id: \.self) { i in
                            Text("\(i)")
                        }
                    }
                    .monospacedBody()
                    .foregroundColor(.primary)
                }
            }

            if let pokemon = viewModel.pokemon {
                Section {
                    NavigationLink(destination: PokemonDetail(pokemon: pokemon, game: settings.currentGame)) {
                        Text("View Pokémon details")
                            .monospacedBody()
                    }
                }

                BattleAssistantInfo(pokemon: pokemon, level: viewModel.level)
            } else {
                Text("Select a Pokémon and level to view helpful info when battling.")
                    .monospacedBody()
            }
        }
        .listStyle(GroupedListStyle())
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
