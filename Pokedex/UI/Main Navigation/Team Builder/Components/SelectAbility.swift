//
//  SelectAbility.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/21/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct SelectAbility: View {

    let form: PokemonForm
    let game: Game
    let onSelect: (Ability) -> Void

    @FetchRequest var abilities: FetchedResults<Ability>

    var body: some View {
        List {
            Section(header: SectionHeader(form.pokemon.name)) {
                if let primaryAbility = form.primaryAbility {
                    AbilityCell(model: .init(ability: primaryAbility)).onTapGesture {
                        self.onSelect(primaryAbility)
                    }
                }
                if let secondaryAbility = form.secondaryAbility {
                    AbilityCell(model: .init(ability: secondaryAbility)).onTapGesture {
                        self.onSelect(secondaryAbility)
                    }
                }
                if let hiddenAbility = form.hiddenAbility {
                    AbilityCell(model: .init(ability: hiddenAbility)).onTapGesture {
                        self.onSelect(hiddenAbility)
                    }
                }
            }

            Section(header: SectionHeader("All Abilities")) {
                ForEach(abilities) { ability in
                    AbilityCell(model: AbilityViewModel(ability: ability)).onTapGesture {
                        self.onSelect(ability)
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Select Ability")
    }

    init(form: PokemonForm, game: Game, onSelect: @escaping (Ability) -> Void) {
        self.form = form
        self.game = game
        self.onSelect = onSelect
        self._abilities = FetchRequest(fetchRequest: Ability.allFetchRequest(for: game))
    }
}

struct SelectAbility_Previews: PreviewProvider {
    static var previews: some View {
        SelectAbility(form: StoredPokemon.generateCharizard().defaultForm, game: .sword, onSelect: { _ in })
    }
}
