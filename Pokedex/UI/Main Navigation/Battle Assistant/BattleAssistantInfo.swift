//
//  BattleAssistantInfo.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/23/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct BattleAssistantInfo: View {

    let pokemon: StoredPokemon
    let level: Int

    @EnvironmentObject var settings: AppSettings

    private var movesFooter: String {
        """
        This list may not include special moves that a Trainer or Gym Leader's Pokémon could use.
        """
    }
    private var padding: CGFloat { 4.0 }
    
    @ViewBuilder var body: some View {
        Section(header: SectionHeader("Types")) {
            PokemonTypeLink(title: "Primary Type", type: pokemon.defaultForm.primaryType, game: settings.currentGame)
            if let secondaryType = pokemon.defaultForm.secondaryType {
                PokemonTypeLink(title: "Secondary Type", type: secondaryType, game: settings.currentGame)
            }
        }

        Section(header: SectionHeader("Move Type Recommendations")) {
            BattleAssistantTypeEffectiveness(
                primaryType: pokemon.defaultForm.primaryType,
                secondaryType: pokemon.defaultForm.secondaryType,
                game: settings.currentGame)
        }
        .padding(.vertical, padding)

        if settings.currentGame.hasAbilities {
            PokemonAbilitiesSection(form: pokemon.defaultForm, game: settings.currentGame)
        }

        Section(header: SectionHeader("Possible Moves (based on level)"), footer: Text(movesFooter).monospacedCaption()) {
            PokemonLearnsetGroup(title: "Level", game: settings.currentGame, learnsetFetchRequest: LevelLearnsetEntry.fetchRequest(forPokemonForm: pokemon.defaultForm, maxLevel: level))
        }
    }

    init(pokemon: StoredPokemon, level: Int) {
        self.pokemon = pokemon
        self.level = level
    }

}

struct BattleAssistantInfo_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                BattleAssistantInfo(pokemon: StoredPokemon.generateCharizard(game: .sword), level: 50)
            }
            .listStyle(GroupedListStyle())
            .injectDependencies()
        }
    }
}

struct PokemonTypeLink: View {

    let title: String
    let type: PokemonType
    let game: Game

    var body: some View {
        NavigationLink(destination: TypeDetail(type: type, game: game)) {
            HStack {
                Text(title)
                    .monospacedBody()
                Spacer()
                Badge(pokemonType: type, equalWidths: true)
            }
        }
    }

}
