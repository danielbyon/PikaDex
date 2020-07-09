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
    var numberKeyPath = #keyPath(Pokemon.z_index)

    private var pokemon: Pokemon { form.pokemon }

    var body: some View {
        HStack {
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
            PokemonFormCellInfo(form: Pokemon.generateCharizard().defaultForm, game: .letsGoPikachu)
            PokemonFormCellInfo(form: Pokemon.generateCharizard().forms[1], game: .letsGoPikachu)
        }
    }
}
