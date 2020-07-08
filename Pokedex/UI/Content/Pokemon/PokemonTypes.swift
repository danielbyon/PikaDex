//
//  PokemonTypes.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/20/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI

struct PokemonTypes: View {

    let primaryType: PokemonType
    let secondaryType: PokemonType?

    var body: some View {
        HStack {
            Badge(pokemonType: primaryType)
            if secondaryType != nil {
                Badge(pokemonType: secondaryType!)
            }
        }
    }

}

struct PokemonTypes_Previews: PreviewProvider {
    static var previews: some View {
        PokemonTypes(primaryType: .fire, secondaryType: .flying)
    }
}
