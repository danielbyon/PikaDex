//
//  BattleAssistantDetail.swift
//  
//
//  Created by Daniel Byon on 10/26/22.
//

import PokedexUI
import SwiftUI

struct BattleAssistantDetail: View {

    let pokemonForm: PokemonDetailForm
    let level: Int

    @Query private var entries: QueryResults<LearnsetEntry>

    private var movesFooter: String {
        """
        This list may not include special moves that a Trainer or Gym Leader's Pokémon could use.
        """
    }
    private var padding: CGFloat { 4.0 }

    var body: some View {
        Section {
            NavigationLink(value: Route.content(.pokemonDetailForm(pokemonForm, pokedex: .national))) {
                Text("View Pokémon details")
                    .monospacedBody()
            }
        }
        .onAppear {
            $entries.wrappedValue = .level(pokemonForm: pokemonForm, maxLevel: level)
        }
        .onChange(of: level) { newValue in
            $entries.wrappedValue = .level(pokemonForm: pokemonForm, maxLevel: newValue)
        }

        Section {
            NavigationLink(value: Route.content(.type(pokemonForm.primaryType, game: pokemonForm.game))) {
                BadgeCell(title: "Primary Type", type: pokemonForm.primaryType)
            }
            if let secondaryType = pokemonForm.secondaryType {
                NavigationLink(value: Route.content(.type(secondaryType, game: pokemonForm.game))) {
                    BadgeCell(title: "Secondary Type", type: secondaryType)
                }
            }
        } header: {
            SectionHeader("Types")
        }

        Section {
            BattleAssistantTypeEffectiveness(
                primaryType: pokemonForm.primaryType,
                secondaryType: pokemonForm.secondaryType,
                game: pokemonForm.game
            )
        } header: {
            SectionHeader("Move Type Recommendations")
        }

        if pokemonForm.game.hasAbilities {
            Section {
                PokemonAbilities(form: pokemonForm, pokedex: .national)
            } header: {
                SectionHeader("Abilities")
            }
        }

        Section {
            ForEach(entries) { entry in
                NavigationLink(value: Route.content(.move(entry.move))) {
                    LearnsetCell(
                        move: entry.move,
                        detailText: entry.detailText,
                        game: pokemonForm.game
                    )
                }
            }
        } header: {
            SectionHeader("Possible Moves (based on level)")
        } footer: {
            Text(movesFooter)
                .monospacedFootnote()
        }
    }

}

