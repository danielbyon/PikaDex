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
            if ability.description(forGame: game) != nil {
                Section {
                    DescriptionCell(text: ability.description(forGame: game)!)
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
                        NavigationLink(destination: PokemonDetail(pokemon: form.pokemon, game: self.game, formIndex: form.formIndex).injectDependencies()) {
                            PokemonFormCell(form: form, game: self.game)
                        }
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle(Text(ability.name), displayMode: .large)
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
