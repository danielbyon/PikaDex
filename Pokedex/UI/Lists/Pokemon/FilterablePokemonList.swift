//
//  FilterablePokemonList.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/23/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct FilterablePokemonList: View {

    @EnvironmentObject var settings: AppSettings
    @State private var isShowingFilter = false
    @StateObject var viewModel = FilterablePokemonListViewModel()

    var body: some View {
        PokemonList(
            fetchRequest: Pokemon.allFetchRequest(for: settings.currentGame, filter: viewModel.filter),
            game: settings.currentGame,
            numberKeyPath: viewModel.filter.filterBy.keyPath)
            .sheet(isPresented: $isShowingFilter) {
                PokemonListFilter(game: self.settings.currentGame, viewModel: self.viewModel)
                    .injectDependencies()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.isShowingFilter.toggle()
                    }) {
                        Image(systemName: viewModel.filter == .defaultFilter(forGame: settings.currentGame)
                                ? "line.horizontal.3.decrease.circle"
                                : "line.horizontal.3.decrease.circle.fill")
                    }
                }
            }
    }

}

struct FilterablePokemonList_Previews: PreviewProvider {
    static var previews: some View {
        FilterablePokemonList()
            .injectDependencies()
    }
}
