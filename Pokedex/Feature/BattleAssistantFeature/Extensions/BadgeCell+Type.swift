//
//  BadgeCell+Type.swift
//  
//
//  Created by Daniel Byon on 10/26/22.
//

import PokedexUI
import SwiftUI

extension BadgeCell {

    init(title: String, type: PokemonType) {
        self.init(
            title: title,
            badge: .init(
                pokemonType: type,
                equalWidths: true
            )
        )
    }

}
