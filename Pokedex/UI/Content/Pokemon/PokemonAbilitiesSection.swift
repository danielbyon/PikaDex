//
//  PokemonAbilitiesSection.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/23/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct PokemonAbilitiesSection: View {

    let form: PokemonForm
    let game: Game

    private var primaryAbility: Ability? { form.primaryAbility }
    private var secondaryAbility: Ability? { form.secondaryAbility }
    private var hiddenAbility: Ability? { form.hiddenAbility }

    var body: some View {
        Section(header: SectionHeader("Abilities")) {
            if let primaryAbility = primaryAbility {
                NavigationLink(destination: AbilityDetail(ability: primaryAbility, game: game)) {
                    PokemonAbilityCell(ability: primaryAbility, game: game)
                }
            }
            if let secondaryAbility = secondaryAbility {
                NavigationLink(destination: AbilityDetail(ability: secondaryAbility, game: game)) {
                    PokemonAbilityCell(ability: secondaryAbility, game: game)
                }
            }
            if let hiddenAbility = hiddenAbility {
                NavigationLink(destination: AbilityDetail(ability: hiddenAbility, game: game)) {
                    PokemonAbilityCell(ability: hiddenAbility, game: game)
                }
            }
        }
    }
}

struct PokemonAbilities_Previews: PreviewProvider {
    static var previews: some View {
        PokemonAbilitiesSection(form: Pokemon.generateCharizard(game: .sword).defaultForm ,game: .sword)
            .injectDependencies()
    }
}
