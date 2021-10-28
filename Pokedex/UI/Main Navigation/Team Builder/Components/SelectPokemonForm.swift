//
//  SelectPokemonForm.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/21/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct SelectPokemonForm: View {

    let game: Game
    let onSelect: (PokemonForm) -> Void

    @Environment(\.dismiss) var dismiss
    @FetchRequest private var pokemonForms: FetchedResults<PokemonForm>

    var body: some View {
        SearchableList(objects: pokemonForms, searchPlaceholder: "Search for a Pokémon") { pokemonForm in
            PokemonFormCell(form: pokemonForm, game: self.game).onTapGesture {
                onSelect(pokemonForm)
                self.dismiss()
            }
        }
        .navigationTitle("Select Pokémon")
    }

    init(game: Game, onSelect: @escaping (PokemonForm) -> Void) {
        self.game = game
        self.onSelect = onSelect
        self._pokemonForms = FetchRequest(fetchRequest: PokemonForm.allFetchRequest(for: game))
    }

}

struct SelectPokemonForm_Previews: PreviewProvider {
    static var previews: some View {
        SelectPokemonForm(game: .sword, onSelect: { _ in })
            .injectDependencies()
    }
}
