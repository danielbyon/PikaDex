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

    let fetchRequest: NSFetchRequest<StoredPokemon>
    let game: Game
    var numberKeyPath: String

    @EnvironmentObject var pokemonStore: PokemonStore
    @FetchRequest private var pokemon: FetchedResults<StoredPokemon>
//    @State private var pokemon: [StoredPokemon] = []
    @State private var selectedPokemon: StoredPokemon?

    var body: some View {
        let _ = Self._printChanges()
        SearchableList(objects: pokemon, searchPlaceholder: "Search for a Pokémon") { pokemon in
            NavigationLink(destination: PokemonDetail(pokemon: pokemon, game: self.game, numberKeyPath: self.numberKeyPath), tag: pokemon, selection: $selectedPokemon) {
                PokemonCell(pokemon: pokemon, game: self.game, numberKeyPath: self.numberKeyPath)
            }
        }
        .navigationTitle("Pokémon")
        .onOpenURL(perform: handleURL)
//        .task {
//            do {
//                let pokemon = try await pokemonStore.fetchPokemon(withFetchRequest: fetchRequest)
//                print(pokemon.count)
//                self.pokemon = pokemon
//            } catch {
//                pokemon = []
//            }
//        }
    }

    init(type: PokemonType, game: Game, numberKeyPath: String = #keyPath(StoredPokemon.z_index)) {
        self.fetchRequest = StoredPokemon.fetchRequest(forType: type, game: game)
        self.game = game
        self.numberKeyPath = numberKeyPath
        self._pokemon = FetchRequest(fetchRequest: StoredPokemon.fetchRequest(forType: type, game: game), animation: .default)
    }

    init(fetchRequest: NSFetchRequest<StoredPokemon>, game: Game, numberKeyPath: String = #keyPath(StoredPokemon.z_index)) {
        self.fetchRequest = fetchRequest
        self.game = game
        self.numberKeyPath = numberKeyPath
        self._pokemon = FetchRequest(fetchRequest: fetchRequest, animation: .default)
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
