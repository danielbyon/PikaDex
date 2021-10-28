//
//  PokemonFormCellInfo.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/2/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct PokemonFormCellInfo: View {

    let form: PokemonForm
    let game: Game
    var showsFormName = true
    var numberKeyPath = #keyPath(StoredPokemon.z_index)

    private var pokemon: StoredPokemon { form.pokemon }

    var body: some View {
        HStack(spacing: 4) {
            PokemonFormSprite(form: form)
            Text(pokemon.pokedexNumberString(forKeyPath: numberKeyPath))
                .monospacedBody()
                .frame(alignment: .trailing)
            VStack(alignment: .leading) {
                Text(pokemon.name)
                    .monospacedBody()
                if showsFormName && form.name != pokemon.name {
                    Text(form.name)
                        .monospacedCaption()
                }
            }
            .frame(alignment: .leading)
        }
    }

}

struct PokemonFormCellInfo_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PokemonFormCellInfo(form: StoredPokemon.generateCharizard().defaultForm, game: .letsGoPikachu)
            PokemonFormCellInfo(form: StoredPokemon.generateCharizard().forms[1], game: .letsGoPikachu)
        }
    }
}
