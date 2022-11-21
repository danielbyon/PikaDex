//
//  PokemonList.swift
//  
//
//  Created by Daniel Byon on 9/19/22.
//

import SwiftUI
import PokedexCore
import PokedexUI

public struct PokemonList: View {

    @Environment(\.userDataDataStore) private var dataStore
    @Query(dataStore: .userData) private var caughtPokemons: QueryResults<CaughtPokemon>
    @Query private var pokemon: QueryResults<Pokemon>
    @State private var currentTab: Tab = .all
    @State private var isShowingFilter = false
    @StateObject private var viewModel = PokemonListViewModel()

    private let game: Game

    private enum Tab: Hashable {
        case all
        case caught
        case uncaught
    }

    public var body: some View {
        Group {
            SearchableList(
                items: pokemon,
                query: $pokemon.query,
                searchPrompt: "Search for a Pokémon",
                id: \.index
            ) { pokemon in
                if shouldDisplayPokemon(pokemon, caughtPokemons: caughtPokemons) {
                    makePokemonCell(pokemon: pokemon, pokedex: viewModel.pokedex)
                }
            }
        }
        .navigationTitle("Pokémon")
        .sheet(isPresented: $isShowingFilter) {
            PokemonFilterView(game: game, filter: $pokemon)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                HomeButton()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    self.isShowingFilter.toggle()
                }) {
                    Image(
                        systemName: viewModel.filter == .default(for: game)
                        ? "line.horizontal.3.decrease.circle"
                        : "line.horizontal.3.decrease.circle.fill"
                    )
                }
            }
            ToolbarItemGroup(placement: .bottomBar) {
                Picker(selection: $currentTab) {
                    Text("All Pokémon")
                        .tag(Tab.all)
                    Text("Caught")
                        .tag(Tab.caught)
                    Text("Uncaught")
                        .tag(Tab.uncaught)
                } label: {
                    EmptyView()
                }
                .pickerStyle(.segmented)
            }
        }
        .onAppear {
            viewModel.dataStore = dataStore
            viewModel.game = game
            $caughtPokemons.wrappedValue = .init(game: game)
            $pokemon.wrappedValue = viewModel.filter
        }
        .onChange(of: $pokemon.wrappedValue) { newValue in
            viewModel.filter = newValue
        }
    }

    public init(game: Game) {
        self.game = game
    }

    private func shouldDisplayPokemon(_ pokemon: Pokemon, caughtPokemons: some RandomAccessCollection<CaughtPokemon>) -> Bool {
        switch currentTab {
        case .all:
            return true
        case .caught:
            let isCaught = caughtPokemons
                .lazy
                .map(\.index)
                .contains(pokemon.index)
            return isCaught
        case .uncaught:
            let isCaught = caughtPokemons
                .lazy
                .map(\.index)
                .contains(pokemon.index)
            return !isCaught
        }
    }

    private func makePokemonCell(pokemon: Pokemon, pokedex: Pokedex) -> some View {
        NavigationLink(value: Route.content(.pokemon(pokemon, pokedex: viewModel.pokedex))) {
            PokemonCell(pokemon: pokemon, pokedex: viewModel.pokedex)
                .contextMenu {
                    NavigationLink(value: Route.content(.pokemon(pokemon, pokedex: pokedex))) {
                        Label("View Details", systemImage: "info.circle")
                    }
                    makeTogglePokemonCaughtButton(pokemon)
                } preview: {
                    PokemonView(pokemon: pokemon, pokedex: pokedex)
                }
                .swipeActions {
                    makeTogglePokemonCaughtButton(pokemon)
                        .labelStyle(.titleOnly)
                }
        }
    }

    private func makeTogglePokemonCaughtButton(_ pokemon: Pokemon) -> some View {
        let isCaught = viewModel.pokemonIsCaught(pokemon, caughtPokemons: caughtPokemons)
        return Button {
            withAnimation {
                if isCaught {
                    viewModel.markPokemonUncaught(pokemon)
                } else {
                    viewModel.markPokemonCaught(pokemon)
                }
            }
        } label: {
            Label(
                isCaught ? "Mark Uncaught" : "Mark Caught",
                systemImage: isCaught ? "checkmark.circle.fill" : "checkmark.circle"
            )
        }
        .tint(isCaught ? .red : .blue)
    }

    private func makeList<Data>(pokemonToDisplay: Data) -> some View where Data: RandomAccessCollection<Pokemon>, Data.Index: Hashable {
        SearchableList(
            items: pokemonToDisplay,
            query: $pokemon.query,
            searchPrompt: "Search for a Pokémon",
            id: \.index
        ) { pokemon in
            NavigationLink(value: Route.content(.pokemon(pokemon, pokedex: viewModel.pokedex))) {
                makePokemonCell(pokemon: pokemon, pokedex: viewModel.pokedex)
            }
        }
    }

}

struct PokemonList_Previews: PreviewProvider {
    static var previews: some View {
        PreviewContainer {
            NavigationStack {
                PokemonList(game: .national)
            }
        }
    }
}
