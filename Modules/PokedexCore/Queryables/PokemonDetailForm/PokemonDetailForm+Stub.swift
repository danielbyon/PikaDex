//
//  PokemonDetailForm+Stub.swift
//  
//
//  Created by Daniel Byon on 10/13/22.
//

import Foundation

extension PokemonDetailForm {

    public static var charizard: PokemonDetailForm {
        .init(
            name: "Charizard",
            pokemonName: "Charizard",
            baseExperienceYield: 0,
            baseFriendship: 0,
            color: .red,
            familyName: "Charizard",
            formIndex: 0,
            game: .sword,
            heightInMeters: 1.7,
            index: 6,
            pokedexEntry: "It spits fire that is hot enough to melt boulders. It may cause forest fires by blowing flames.",
            primaryType: .fire,
            secondaryType: .flying,
            species: "Flame",
            weightInKilograms: 90.5,
            spriteName: "006-menusprite",
            baseStats: .init(
                attack: 78,
                defense: 84,
                hp: 78,
                specialAttack: 109,
                specialDefense: 85,
                speed: 100
            ),
            evolutions: nil,
            evYield: .init(
                attack: 0,
                defense: 0,
                hp: 0,
                specialAttack: 3,
                specialDefense: 0,
                speed: 0
            ),
            hiddenAbility: nil,
            primaryAbility: nil,
            secondaryAbility: nil,
            pokedexNumbers: .init(national: 6, galar: 380)
        )
    }
    
}
