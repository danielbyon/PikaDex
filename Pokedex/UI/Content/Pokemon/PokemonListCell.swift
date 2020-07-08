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

    private var form: PokemonForm { pokemon.defaultForm }

    var body: some View {
        HStack {
            Image(form.spriteName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40.0, height: 40.0)
            Text(pokemon.nationalPokedexNumberString)
                .monospacedBody()
                .frame(alignment: .trailing)
            Text(pokemon.name)
                .monospacedBody()
                .frame(alignment: .leading)

            Spacer()
            VStack(spacing: 2.0) {
                Badge(pokemonType: form.primaryType, equalWidths: true, isSmall: true)
                if form.secondaryType != nil {
                    Badge(pokemonType: form.secondaryType!, equalWidths: true, isSmall: true)
                }
            }
        }
    }

}

struct PokemonListCell_Previews: PreviewProvider {
    static var previews: some View {
        PokemonCell(pokemon: Pokemon.generateCharizard(), game: .sword)
    }
}
