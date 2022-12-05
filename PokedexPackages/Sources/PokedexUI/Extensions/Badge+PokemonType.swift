//
//  Badge+PokemonType.swift
//  
//
//  Created by Daniel Byon on 9/28/22.
//

import DesignSystem

extension Badge {

    public init(pokemonType: PokemonType, equalWidths: Bool = false, isSmall: Bool = false) {
        self.init(
            title: pokemonType.rawValue,
            fillColor: pokemonType.color,
            equalWidths: equalWidths,
            isSmall: isSmall
        )
    }

}
