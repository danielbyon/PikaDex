//
//  PokemonCell.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/13/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI

struct PokemonCell: View {

    let pokemon: Pokemon
    let game: Game
    var numberKeyPath = #keyPath(Pokemon.z_index)

    var body: some View {
        PokemonFormCell(form: pokemon.defaultForm, game: game, showsFormName: false, numberKeyPath: numberKeyPath)
    }

}

struct PokemonListCell_Previews: PreviewProvider {
    static var previews: some View {
        PokemonCell(pokemon: Pokemon.generateCharizard(), game: .sword)
    }
}
