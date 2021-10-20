//
//  FilterablePokemonList.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/23/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct FilterablePokemonList: View {

    let game: Game

    @State private var isShowingFilter = false
    @StateObject var viewModel = FilterablePokemonListViewModel()

    var body: some View {
        PokemonList(
            fetchRequest: StoredPokemon.allFetchRequest(for: game, filter: viewModel.filter),
            game: game,
            numberKeyPath: viewModel.filter.filterBy.keyPath)
            .id(viewModel.filter)
            .sheet(isPresented: $isShowingFilter) {
                PokemonListFilter(game: game, viewModel: viewModel)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.isShowingFilter.toggle()
                    }) {
                        Image(systemName: viewModel.filter == .defaultFilter(forGame: game)
                                ? "line.horizontal.3.decrease.circle"
                                : "line.horizontal.3.decrease.circle.fill")
                    }
                }
            }
    }

}

struct FilterablePokemonList_Previews: PreviewProvider {
    static var previews: some View {
        FilterablePokemonList(game: .sword)
            .injectDependencies()
    }
}
