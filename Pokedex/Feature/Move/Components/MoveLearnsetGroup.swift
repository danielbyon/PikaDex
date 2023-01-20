//
//  MoveLearnsetGroup.swift
//  
//
//  Created by Daniel Byon on 10/5/22.
//

import DesignSystem
import PokedexUI
import SwiftUI

struct MoveLearnsetGroup: View {

    let title: String
    let game: Game
    let entries: QueryResults<PokedexCore.LearnsetEntry>

    var body: some View {
        if !entries.isEmpty {
            ForEach(entries) { entry in
                NavigationLink(value: Route.content(.learnsetPokemonForm(entry.pokemonForm))) {
                    PokemonCell(learnsetPokemonForm: entry.pokemonForm)
                }
            }
        } else {
            Text("No Pokémon learns this move by \(title).")
        }
    }

}
