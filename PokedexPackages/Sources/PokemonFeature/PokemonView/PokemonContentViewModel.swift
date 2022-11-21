//
//  PokemonContentViewModel.swift
//  
//
//  Created by Daniel Byon on 11/4/22.
//

import PokedexUI
import SwiftUI

final class PokemonContentViewModel: ObservableObject {

    let pokemon: PokemonDetail
    let pokedex: Pokedex

    var dataStore: DataStore?

    var isCaught: Bool {
        let filter = CaughtPokemonFilter(pokemonDetail: pokemon)
        let caughtPokemon = (try? dataStore?.fetch(CaughtPokemon.self, filter: filter)) ?? []
        return !caughtPokemon.isEmpty
    }

    init(
        pokemon: PokemonDetail,
        pokedex: Pokedex
    ) {
        self.pokemon = pokemon
        self.pokedex = pokedex
    }

    func markCaught() {
        let caughtPokemon = CaughtPokemon(pokemonDetail: pokemon)
        do {
            try dataStore?.save(caughtPokemon)
            objectWillChange.send()
        } catch {
            debugPrint(error)
        }
    }

    func markUncaught() {
        let caughtPokemon = CaughtPokemon(pokemonDetail: pokemon)
        do {
            try dataStore?.remove(CaughtPokemon.self, filter: .init(caughtPokemon: caughtPokemon))
            objectWillChange.send()
        } catch {
            debugPrint(error)
        }
    }


}
