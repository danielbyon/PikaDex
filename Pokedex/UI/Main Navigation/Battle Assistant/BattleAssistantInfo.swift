//
//  BattleAssistantInfo.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/23/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct BattleAssistantInfo: View {

    let pokemon: Pokemon
    let level: Int

    @EnvironmentObject var appContext: AppContext

    private var movesFooter: String {
        """
        This list may not include special moves that a Trainer or Gym Leader's Pokémon could use.
        """
    }
    private var padding: CGFloat { 4.0 }
    
    @ViewBuilder var body: some View {
        Section(header: SectionHeader("Types")) {
            PokemonTypeLink(title: "Primary Type", type: pokemon.defaultForm.primaryType, game: appContext.currentGame)
            if pokemon.defaultForm.secondaryType != nil {
                PokemonTypeLink(title: "Secondary Type", type: pokemon.defaultForm.secondaryType!, game: appContext.currentGame)
            }
        }

        Section(header: SectionHeader("Move Type Recommendations")) {
            BattleAssistantTypeEffectiveness(
                primaryType: pokemon.defaultForm.primaryType,
                secondaryType: pokemon.defaultForm.secondaryType,
                game: appContext.currentGame)
        }
        .padding(.vertical, padding)

        if appContext.currentGame.hasAbilities {
            PokemonAbilitiesSection(form: pokemon.defaultForm, game: appContext.currentGame)
        }

        Section(header: SectionHeader("Possible Moves (based on level)"), footer: Text(movesFooter).monospacedCaption()) {
            PokemonLearnsetGroup(title: "Level", game: appContext.currentGame, learnsetFetchRequest: LevelLearnsetEntry.fetchRequest(forPokemonForm: pokemon.defaultForm, maxLevel: level))
        }
    }

    init(pokemon: Pokemon, level: Int) {
        self.pokemon = pokemon
        self.level = level
    }

}

struct BattleAssistantInfo_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                BattleAssistantInfo(pokemon: Pokemon.generateCharizard(game: .sword), level: 50)
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
        NavigationLink(destination: TypeDetail(type: type, game: game).injectDependencies()) {
            HStack {
                Text(title)
                    .monospacedBody()
                Spacer()
                Badge(pokemonType: type, equalWidths: true)
            }
        }
    }

}
