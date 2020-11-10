//
//  AbilityDetail.swift
//  Pokedex
//
//  Created by Daniel Byon on 2/25/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct AbilityDetail: View {

    let ability: Ability
    let game: Game

    @FetchRequest private var forms: FetchedResults<PokemonForm>

    var body: some View {
        List {
            if let description = ability.description(forGame: game) {
                Section {
                    DescriptionCell(text: description)
                }
            }

            Section {
                Value1Cell(text: "Introduced", detailText: ability.generationIntroduced.title)
            }

            Section(header: SectionHeader("Pokémon")) {
                if forms.isEmpty {
                    Text("No Pokémon have this ability in Pokémon \(game.title).")
                        .monospacedBody()
                } else {
                    AlternatingBackgroundForEach(forms) { form in
                        NavigationLink(destination: PokemonDetail(pokemon: form.pokemon, game: self.game, formIndex: form.formIndex)) {
                            PokemonFormCell(form: form, game: self.game)
                        }
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle(ability.name)
    }

    init(ability: Ability, game: Game) {
        self.ability = ability
        self.game = game
        self._forms = FetchRequest(fetchRequest: PokemonForm.fetchRequest(for: ability, game: game))
    }

}

struct AbilityDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
        AbilityDetail(ability: Ability.generateBlaze(), game: .sword)
            .injectDependencies()
        }
    }
}
