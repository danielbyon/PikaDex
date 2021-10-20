//
//  PokemonCell.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/13/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI

struct PokemonCell: View {

    let pokemon: StoredPokemon
    let game: Game
    var numberKeyPath = #keyPath(StoredPokemon.z_index)

    var body: some View {
        PokemonFormCell(form: pokemon.defaultForm, game: game, showsFormName: false, numberKeyPath: numberKeyPath)
    }

}

struct PokemonListCell_Previews: PreviewProvider {
    static var previews: some View {
        PokemonCell(pokemon: StoredPokemon.generateCharizard(), game: .sword)
    }
}
