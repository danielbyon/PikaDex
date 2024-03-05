//
//  DualTypeChecker.swift
//  
//
//  Created by Daniel Byon on 10/22/22.
//

import PokedexUI
import SwiftUI

public struct DualTypeChecker: View {

    let game: Game

    @Query private var pokemonForms: QueryResults<PokemonDetailForm>
    @State private var firstType: PokemonType = .fire
    @State private var secondType: PokemonType = .flying

    private var types: [PokemonType] { PokemonType.allCases.sorted() }

    public var body: some View {
        Form {
            Section {
                TypeSelector(title: "First Type", selectedType: $firstType)
                TypeSelector(title: "Second Type", selectedType: $secondType)
            }

            Section {
                PokemonTypeEffectiveness(
                    primaryType: firstType,
                    secondaryType: secondType,
                    kind: .defense,
                    game: game
                )
            } header: {
                SectionHeader("Type Effectiveness")
            }

            Section {
                DualTypePokemonForms(
                    firstType: firstType,
                    secondType: secondType,
                    game: game,
                    pokemonForms: pokemonForms
                )
            } header: {
                SectionHeader("Pokemon")
            }
        }
        .navigationTitle("Dual Type Checker")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                HomeButton()
            }
        }
        .onAppear {
            $pokemonForms.wrappedValue = .init(
                firstType: firstType,
                secondType: secondType,
                game: game
            )
        }
        .onChange(of: firstType) { _, newType in
            updateFilter(forType: newType)
        }
        .onChange(of: secondType) { _, newType in
            updateFilter(forType: newType)
        }
    }

    private func updateFilter(forType type: PokemonType) {
        $pokemonForms.wrappedValue = .init(
            firstType: firstType,
            secondType: secondType,
            game: game
        )
    }

}

struct DualTypeChecker_Previews: PreviewProvider {
    static var previews: some View {
        DualTypeChecker(game: .sword)
    }
}
