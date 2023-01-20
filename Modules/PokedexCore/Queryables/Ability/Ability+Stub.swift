//
//  Ability+Stub.swift
//  
//
//  Created by Daniel Byon on 10/21/22.
//

import Foundation

extension Ability {

    public static var blaze: Ability {
        .init(
            generationIntroduced: 3,
            index: 0,
            name: "Blaze",
            descriptions: [
                .sword: "Powers up Fire-type moves when the Pokémon’s HP is low."
            ],
            bulbapediaURL: URL(string: "http://bulbapedia.bulbagarden.net/wiki/Blaze_(Ability)")!,
            pokemonDBURL: URL(string: "https://pokemondb.net/ability/blaze")!
        )
    }

}
