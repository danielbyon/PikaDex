//
//  SelectAbility.swift
//  
//
//  Created by Daniel Byon on 10/31/22.
//

import PokedexUI
import SwiftUI

struct SelectAbility: View {

    let pokemonForm: PokemonDetailForm
    let game: Game
    let currentAbility: Ability?
    let onSelect: (Ability) -> Void

    @Environment(\.dismiss) private var dismiss
    @Query private var abilities: QueryResults<Ability>

    private var pokemonAbilities: [Ability] {
        [pokemonForm.primaryAbility, pokemonForm.secondaryAbility, pokemonForm.hiddenAbility].compactMap { $0 }
    }

    var body: some View {
        List {
            Section {
                ForEach(pokemonAbilities, id: \.self) { ability in
                    makeAbilityCell(ability)
                }
            } header: {
                SectionHeader(pokemonForm.pokemonName)
            }

            Section {
                ForEach(abilities, id: \.self) { ability in
                    makeAbilityCell(ability)
                }
            } header: {
                SectionHeader("All Abilities")
            }
        }
        .listStyle(.grouped)
        .navigationTitle("Select Ability")
        .onAppear {
            $abilities.wrappedValue = .init(game: game)
        }
    }

    private func makeAbilityCell(_ ability: Ability) -> some View {
        HStack {
            AbilityCell(ability: ability)
            Spacer()
            if let currentAbility,
               currentAbility == ability {
                Image(systemName: "checkmark")
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect(ability)
            dismiss()
        }
    }

}

struct SelectAbility_Previews: PreviewProvider {
    static var previews: some View {
        SelectAbility(
            pokemonForm: .charizard,
            game: .sword,
            currentAbility: nil,
            onSelect: { _ in }
        )
    }
}
