//
//  SelectPokemonForm.swift
//  
//
//  Created by Daniel Byon on 10/23/22.
//

import PokedexUI
import SwiftUI

public struct SelectPokemonForm: View {

    let game: Game

    @Environment(\.dismiss) private var dismiss
    @Environment(\.selectPokemonForm) private var selectPokemonForm
    @Query private var pokemonForms: QueryResults<PokemonDetailForm>

    public var body: some View {
        SearchableList(
            items: pokemonForms,
            query: $pokemonForms.query.toString(),
            searchPrompt: "Search for a Pokémon",
            id: \.self
        ) { pokemonForm in
            PokemonCell(pokemonForm: pokemonForm)
                .onTapGesture {
                    selectPokemonForm(pokemonForm)
                    dismiss()
                }
        }
        .navigationTitle("Select Pokémon")
        .onAppear {
            $pokemonForms.wrappedValue = .init(game: game)
        }
    }

    public init(game: Game) {
        self.game = game
    }

}

struct SelectPokemon_Previews: PreviewProvider {
    static var previews: some View {
        PreviewContainer {
            SelectPokemonForm(game: .sword)
                .onSelectPokemonForm { _ in }
        }
    }
}
