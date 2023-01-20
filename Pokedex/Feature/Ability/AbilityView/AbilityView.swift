//
//  AbilityView.swift
//  
//
//  Created by Daniel Byon on 9/28/22.
//

import PokedexUI
import SwiftUI

public struct AbilityView: View {

    @Query private var pokemonForms: QueryResults<AbilityPokemonForm>

    public let ability: Ability
    public let game: Game
    public let pokedex: Pokedex

    public var body: some View {
        List {
            if let description = ability[game] {
                Section {
                    DescriptionCell(text: description)
                }
            }

            Section {
                Value1Cell(text: "Introduced", detailText: ability.generationIntroduced.title)
            }

            Section {
                if pokemonForms.isEmpty {
                    Text("No Pokémon have this ability in Pokémon \(game.title).")
                        .monospacedBody()
                } else {
                    ForEach(pokemonForms, id: \.self) { form in
                        NavigationLink(value: Route.content(.abilityPokemonForm(form, pokedex: pokedex))) {
                            PokemonCell(abilityPokemonForm: form)
                        }
                    }
                }
            } header: {
                SectionHeader("Pokémon")
            }

            Section {
                NavigationLink(value: Route.url(ability.bulbapediaURL)) {
                    Text("View on Bulbapedia")
                }
                NavigationLink(value: Route.url(ability.pokemonDBURL)) {
                    Text("View on Pokemon DB")
                }
            } footer: {
                ExternalLinksDisclaimer()
            }
        }
        .listStyle(.grouped)
        .navigationTitle(ability.name)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                HomeButton()
            }
        }
        .onAppear {
            $pokemonForms.wrappedValue = .init(ability: ability, game: game)
        }
    }

    public init(
        ability: Ability,
        game: Game,
        pokedex: Pokedex
    ) {
        self.ability = ability
        self.game = game
        self.pokedex = pokedex
    }

}

struct AbilityView_Previews: PreviewProvider {
    static var previews: some View {
        AbilityView(
            ability: .blaze,
            game: .sword,
            pokedex: .galar
        )
    }
}
