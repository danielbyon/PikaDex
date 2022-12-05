//
//  PokemonAbilities.swift
//  
//
//  Created by Daniel Byon on 9/23/22.
//

import PokedexUI
import SwiftUI

public struct PokemonAbilities: View {

    let form: PokemonDetailForm
    let pokedex: Pokedex

    private var primaryAbility: Ability? { form.primaryAbility }
    private var secondaryAbility: Ability? { form.secondaryAbility }
    private var hiddenAbility: Ability? { form.hiddenAbility }

    public var body: some View {
        if let primaryAbility = primaryAbility {
            NavigationLink(value: Route.content(.ability(primaryAbility, game: form.game, pokedex: pokedex))) {
                PokemonAbilityRow(ability: primaryAbility, game: form.game)
            }
        }
        if let secondaryAbility = secondaryAbility {
            NavigationLink(value: Route.content(.ability(secondaryAbility, game: form.game, pokedex: pokedex))) {
                PokemonAbilityRow(ability: secondaryAbility, game: form.game)
            }
        }
        if let hiddenAbility = hiddenAbility {
            NavigationLink(value: Route.content(.ability(hiddenAbility, game: form.game, pokedex: pokedex))) {
                PokemonAbilityRow(ability: hiddenAbility, game: form.game, isHidden: true)
            }
        }
    }

    public init(
        form: PokemonDetailForm,
        pokedex: Pokedex
    ) {
        self.form = form
        self.pokedex = pokedex
    }

}

struct PokemonAbilities_Previews: PreviewProvider {
    static var previews: some View {
        PokemonAbilities(
            form: .init(
                name: "Charizard",
                pokemonName: "Charizard",
                baseExperienceYield: 0,
                baseFriendship: 0,
                color: .red,
                familyName: "Charmander",
                formIndex: 0,
                game: .sword,
                heightInMeters: 1.7,
                index: 6,
                pokedexEntry: "It spits fire that is hot enough to melt boulders. It may cause forest fires by blowing flames.",
                primaryType: .fire,
                secondaryType: nil,
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
                evolutions: [],
                evYield: .init(
                    attack: 0,
                    defense: 0,
                    hp: 0,
                    specialAttack: 0,
                    specialDefense: 0,
                    speed: 0
                ),
                hiddenAbility: nil,
                primaryAbility: nil,
                secondaryAbility: nil,
                pokedexNumbers: .init(national: 6, galar: 380)
            ),
            pokedex: .galar
        )
    }
}
