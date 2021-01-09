//
//  PokemonFormCell.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/9/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct PokemonFormCell: View {

    let form: PokemonForm
    let game: Game
    var showsFormName = true
    var numberKeyPath = #keyPath(Pokemon.z_index)

    private var pokemon: Pokemon { form.pokemon }

    var body: some View {
        HStack(spacing: 0) {
            PokemonFormCellInfo(form: form, game: game, showsFormName: showsFormName, numberKeyPath: numberKeyPath)

            Spacer(minLength: 2)
            VStack(spacing: 2) {
                Badge(pokemonType: form.primaryType, equalWidths: true, isSmall: true)
                if let secondaryType = form.secondaryType {
                    Badge(pokemonType: secondaryType, equalWidths: true, isSmall: true)
                }
            }
        }
        .contentShape(Rectangle())
    }
}

struct PokemonFormCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PokemonFormCell(form: Pokemon.generateCharizard().defaultForm, game: .letsGoPikachu)
            PokemonFormCell(form: Pokemon.generateCharizard().forms[1], game: .letsGoPikachu)
        }
    }
}
