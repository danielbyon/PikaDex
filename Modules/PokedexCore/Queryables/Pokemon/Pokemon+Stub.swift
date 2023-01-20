//
//  Pokemon+Stub.swift
//  
//
//  Created by Daniel Byon on 10/17/22.
//

import Foundation

extension Pokemon {

    public static var charizard: Pokemon {
        .init(
            game: .sword,
            generationIntroduced: 1,
            index: 6,
            name: "Charizard",
            primaryType: .fire,
            secondaryType: .flying,
            spriteName: "006-menusprite",
            pokedexNumbers: .init(national: 6, kanto: 6)
        )
    }

}
