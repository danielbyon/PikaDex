//
//  SelectPokemon.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/22/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct SelectPokemon: View {

    let game: Game
    let onSelect: (Pokemon) -> Void

    @FetchRequest private var pokemon: FetchedResults<Pokemon>

    var body: some View {
        SearchableList(viewModel: SearchableListViewModel(objects: pokemon), searchPlaceholder: "Search for a Pokémon") { pokemon in
            PokemonCell(pokemon: pokemon, game: self.game).onTapGesture {
                self.onSelect(pokemon)
            }
        }
        .navigationTitle("Select Pokémon")
    }

    init(game: Game, onSelect: @escaping (Pokemon) -> Void) {
        self.game = game
        self.onSelect = onSelect
        self._pokemon = FetchRequest(fetchRequest: Pokemon.allFetchRequest(for: game, filter: .defaultFilter(forGame: game)))
    }

}

struct SelectPokemon_Previews: PreviewProvider {
    static var previews: some View {
        SelectPokemon(game: .sword, onSelect: { _ in })
            .injectDependencies()
    }
}

private struct SelectPokemonCell: View {

    let pokemon: Pokemon

    var body: some View {
        HStack {
            Text(pokemon.name)
                .monospacedBody()
            Spacer()
        }
        .contentShape(Rectangle())
    }

}
