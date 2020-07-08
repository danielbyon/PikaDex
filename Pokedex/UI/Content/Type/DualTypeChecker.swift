//
//  DualTypeDetail.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/4/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct DualTypeDetail: View {

    let game: Game

    @EnvironmentObject var appContext: AppContext
    @State private var firstType: PokemonType = .fire
    @State private var secondType: PokemonType = .flying

    var body: some View {
        List {
            Section {
                NavigationLink(destination: TypeSelector(selectedType: $firstType)) {
                    Text(firstType.rawValue)
                        .monospacedBody()
                }
                NavigationLink(destination: TypeSelector(selectedType: $secondType)) {
                    Text(secondType.rawValue)
                        .monospacedBody()
                }
            }

            Section(header: SectionHeader("Type Effectiveness")) {
                PokemonTypeEffectiveness(primaryType: firstType, secondaryType: secondType, kind: .defense, game: appContext.currentGame)
            }
            .padding(.vertical, 4.0)

            Section(header: SectionHeader("Pokémon")) {
                PokemonFormsForEach(firstType: firstType, secondType: secondType, game: game)
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Dual Type Checker", displayMode: .inline)
    }
//
//    init(firstType: PokemonType = .fire, secondType: PokemonType = .flying, game: Game) {
//        _firstType = State(initialValue: firstType)
//        _secondType = State(initialValue: secondType)
//        self.game = game
//    }

}

struct DualTypeChecker_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DualTypeDetail(game: .sword)
        }
        .injectDependencies()
    }
}

private struct ViewModel: Identifiable {

    let id = UUID()

}

struct PokemonFormsForEach: View {

    let game: Game

    @FetchRequest private var pokemonForms: FetchedResults<PokemonForm>

    var body: some View {
        ForEach(pokemonForms) { form in
            NavigationLink(destination: PokemonDetail(pokemon: form.pokemon, game: self.game, formIndex: form.formIndex)) {
                PokemonFormCell(form: form, game: self.game)
            }
        }
    }

    init(firstType: PokemonType = .fire, secondType: PokemonType = .flying, game: Game) {
        self.game = game
        _pokemonForms = FetchRequest(fetchRequest: PokemonForm.fetchRequest(forFirstType: firstType, secondType: secondType, game: game))
    }

}
