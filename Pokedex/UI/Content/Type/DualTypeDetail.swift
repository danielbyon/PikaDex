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

    @EnvironmentObject var settings: AppSettings
    @State private var firstType: PokemonType = .fire
    @State private var secondType: PokemonType = .flying

    private var types: [PokemonType] { PokemonType.allCases.sorted() }

    var body: some View {
        Form {
            Section {
                TypeSelector(title: "First Type", selectedType: $firstType)
                TypeSelector(title: "Second Type", selectedType: $secondType)
            }

            Section(header: SectionHeader("Type Effectiveness")) {
                PokemonTypeEffectiveness(primaryType: firstType, secondaryType: secondType, kind: .defense, game: settings.currentGame)
            }
            .padding(.vertical, 4.0)

            Section(header: SectionHeader("Pokémon")) {
                PokemonFormsForEach(firstType: firstType, secondType: secondType, game: game)
            }
        }
        .navigationTitle("Dual Type Checker")
    }

}

struct DualTypeDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DualTypeDetail(game: .sword)
        }
        .injectDependencies()
    }
}

private struct PokemonFormsForEach: View {

    let firstType: PokemonType
    let secondType: PokemonType
    let game: Game

    @FetchRequest private var pokemonForms: FetchedResults<PokemonForm>

    var body: some View {
        Group {
            if pokemonForms.isEmpty {
                Text("No Pokémon with types \(firstType.rawValue) and \(secondType.rawValue) in Pokémon \(game.title).")
                    .monospacedBody()
            } else {
                AlternatingBackgroundForEach(pokemonForms) { form in
                    NavigationLink(destination: PokemonDetail(pokemon: form.pokemon, game: self.game, formIndex: form.formIndex)) {
                        PokemonFormCell(form: form, game: self.game)
                    }
                }
            }
        }
    }

    init(firstType: PokemonType, secondType: PokemonType, game: Game) {
        self.firstType = firstType
        self.secondType = secondType
        self.game = game
        _pokemonForms = FetchRequest(fetchRequest: PokemonForm.fetchRequest(forFirstType: firstType, secondType: secondType, game: game))
    }

}
