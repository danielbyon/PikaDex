//
//  DualTypePokemonForms.swift
//  
//
//  Created by Daniel Byon on 10/23/22.
//

import PokedexUI
import SwiftUI

struct DualTypePokemonForms: View {

    let firstType: PokemonType
    let secondType: PokemonType
    let game: Game
    let pokemonForms: QueryResults<PokemonDetailForm>

    var body: some View {
        if pokemonForms.isEmpty {
            Text("No Pokémon with types \(firstType.rawValue) and \(secondType.rawValue) in Pokémon \(game.title).")
                .monospacedBody()
        } else {
            ForEach(pokemonForms, id: \.self) { pokemonForm in
                NavigationLink(value: Route.content(.pokemonDetailForm(pokemonForm, pokedex: .national))) {
                    PokemonCell(pokemonForm: pokemonForm)
                }
            }
        }
    }

}
