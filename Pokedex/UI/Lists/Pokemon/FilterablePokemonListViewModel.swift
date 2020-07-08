//
//  FilterablePokemonListViewModel.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/24/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import AppSupport

final class FilterablePokemonListViewModel: ObservableObject {

    @UserDefault(key: "pokemonlistfilter.filter", defaultValue: .defaultFilter(forGame: Dependencies.appContext.currentGame)) var filter: Pokemon.Filter {
        willSet {
            objectWillChange.send()
        }
    }

    @UserDefault(key: "pokemonlistfilter.game", defaultValue: .sword) private var game: Game

    init() {
        // Make sure the filter we're hydrating is for the current game
        validateFilter()
        // Save the current game for hydrating next time
        self.game = Dependencies.appContext.currentGame
    }

    private func validateFilter() {
        if game != Dependencies.appContext.currentGame {
            self.filter = self._filter.defaultValue
        }
    }

}
