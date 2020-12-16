//
//  PokemonList.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/17/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI
import CoreData

struct PokemonList: View {

    let game: Game
    var numberKeyPath: String

    @FetchRequest private var pokemon: FetchedResults<Pokemon>
    @State private var selectedPokemon: Pokemon?

    var body: some View {
        SearchableList(viewModel: SearchableListViewModel(objects: pokemon), searchPlaceholder: "Search for a Pokémon") { pokemon in
            NavigationLink(destination: PokemonDetail(pokemon: pokemon, game: self.game, numberKeyPath: self.numberKeyPath), tag: pokemon, selection: $selectedPokemon) {
                PokemonCell(pokemon: pokemon, game: self.game, numberKeyPath: self.numberKeyPath)
            }
        }
        .navigationTitle("Pokémon")
        .onOpenURL(perform: handleURL)
    }

    init(type: PokemonType, game: Game, numberKeyPath: String = #keyPath(Pokemon.z_index)) {
        self.game = game
        self.numberKeyPath = numberKeyPath
        self._pokemon = FetchRequest(fetchRequest: Pokemon.fetchRequest(forType: type, game: game), animation: .default)
    }

    init(fetchRequest: NSFetchRequest<Pokemon>, game: Game, numberKeyPath: String = #keyPath(Pokemon.z_index)) {
        self.game = game
        self.numberKeyPath = numberKeyPath
        self._pokemon = FetchRequest(fetchRequest: fetchRequest, animation: .default)
    }

    init(fetchRequest: FetchRequest<Pokemon>, game: Game, numberKeyPath: String = #keyPath(Pokemon.z_index)) {
        self.game = game
        self.numberKeyPath = numberKeyPath
        self._pokemon = fetchRequest
    }

    private func handleURL(_ url: URL) {
        guard let pokemonName = url.pokemon,
              let pokemonToSelect = pokemon.first(where: { $0.name == pokemonName }) else { return }
        DispatchQueue.main.async {
            selectedPokemon = pokemonToSelect
        }
    }

}

struct PokemonList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PokemonList(type: .fire, game: .sword)
                .injectDependencies()
        }
    }
}
