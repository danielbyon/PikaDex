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

    @AppGroupStorage(key: "pokemonlistfilter.filter", defaultValue: .defaultFilter(forGame: Dependencies.settings.currentGame))
    var filter: StoredPokemon.Filter {
        willSet {
            objectWillChange.send()
        }
    }

    @AppGroupStorage(key: "pokemonlistfilter.game", defaultValue: .sword)
    private var game: Game

    init() {
        // Make sure the filter we're hydrating is for the current game
        validateFilter()
        // Save the current game for hydrating next time
        self.game = Dependencies.settings.currentGame
    }

    private func validateFilter() {
        if game != Dependencies.settings.currentGame {
            self.filter = self._filter.defaultValue
        }
    }

}
