//
//  PokemonDetail+Stub.swift
//  
//
//  Created by Daniel Byon on 10/17/22.
//

import Foundation

extension PokemonDetail {

    public static var charizard: PokemonDetail {
        .init(
            name: "Charizard",
            index: 6,
            game: .sword,
            generationIntroduced: 1,
            forms: [.charizard],
            pokedexNumbers: .init(national: 6, kanto: 6),
            catchRate: 0,
            eggGroups: [],
            levelingRate: .slow,
            maleRatio: 50,
            bulbapediaURL: URL(string: "https://bulbapedia.bulbagarden.net/wiki/Charizard_(Pokémon)")!,
            pokemonDBURL: URL(string: "https://pokemondb.net/pokedex/bulbasaur")!
        )
    }

}
