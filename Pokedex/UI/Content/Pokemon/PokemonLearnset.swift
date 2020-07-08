//
//  PokemonLearnset.swift
//  Pokedex
//
//  Created by Daniel Byon on 2/23/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct PokemonLearnset: View {

    let form: PokemonForm
    let game: Game

    @State private var selectedLearnsetType: LearnsetType

    var body: some View {
        List {
            SegmentedControl(titles: LearnsetType.allTitles(for: game), values: LearnsetType.allCases(for: game), selectedSegmentIndex: $selectedLearnsetType)
            if selectedLearnsetType == .level {
                PokemonLearnsetGroup(title: "Level", game: game, learnsetFetchRequest: LevelLearnsetEntry.fetchRequest(forPokemonForm: form))
            } else if selectedLearnsetType == .machine {
                PokemonLearnsetGroup(title: "Machine", game: game, learnsetFetchRequest: MachineLearnsetEntry.fetchRequest(forPokemonForm: form))
            } else if selectedLearnsetType == .breed {
                PokemonLearnsetGroup(title: "Breeding", game: game, learnsetFetchRequest: BreedLearnsetEntry.fetchRequest(forPokemonForm: form))
            } else if selectedLearnsetType == .tutor {
                PokemonLearnsetGroup(title: "Tutoring", game: game, learnsetFetchRequest: TutorLearnsetEntry.fetchRequest(forPokemonForm: form))
            }
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle("Moves", displayMode: .inline)
    }

    init(form: PokemonForm, game: Game, initialLearnsetType learnsetType: LearnsetType) {
        self.form = form
        self.game = game
        self._selectedLearnsetType = .init(initialValue: learnsetType)
    }

}

struct PokemonLearnset_Previews: PreviewProvider {
    static var previews: some View {
        PokemonLearnset(form: Pokemon.generateCharizard().defaultForm, game: .sword, initialLearnsetType: .level)
            .modifier(Dependencies())
    }
}
