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
            SegmentedControl(selectedSegment: $selectedLearnsetType, segments: LearnsetType.allCases(for: game))
            switch selectedLearnsetType {
            case .level:
                PokemonLearnsetGroup(title: "Level", game: game, learnsetFetchRequest: LevelLearnsetEntry.fetchRequest(forPokemonForm: form))
            case .machine:
                PokemonLearnsetGroup(title: "Machine", game: game, learnsetFetchRequest: MachineLearnsetEntry.fetchRequest(forPokemonForm: form))
            case .breed:
                PokemonLearnsetGroup(title: "Breeding", game: game, learnsetFetchRequest: BreedLearnsetEntry.fetchRequest(forPokemonForm: form))
            case .tutor:
                PokemonLearnsetGroup(title: "Tutoring", game: game, learnsetFetchRequest: TutorLearnsetEntry.fetchRequest(forPokemonForm: form))
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Moves")
    }

//    private var gameToShow: Game { game == .national ? form.pokemon.generationIntroduced.defaultGame : game }
//    private var shouldShowNationalBanner: Bool { game == .national }
//
//    var body: some View {
//        List {
//            if shouldShowNationalBanner {
//                Text("Showing move data for Pokémon \(gameToShow.title)")
//            }
//            SegmentedControl(selectedSegment: $selectedLearnsetType, segments: LearnsetType.allCases(for: gameToShow))
//            switch selectedLearnsetType {
//            case .level:
//                PokemonLearnsetGroup(title: "Level", game: gameToShow, learnsetFetchRequest: LevelLearnsetEntry.fetchRequest(forPokemonForm: form))
//            case .machine:
//                PokemonLearnsetGroup(title: "Machine", game: gameToShow, learnsetFetchRequest: MachineLearnsetEntry.fetchRequest(forPokemonForm: form))
//            case .breed:
//                PokemonLearnsetGroup(title: "Breeding", game: gameToShow, learnsetFetchRequest: BreedLearnsetEntry.fetchRequest(forPokemonForm: form))
//            case .tutor:
//                PokemonLearnsetGroup(title: "Tutoring", game: gameToShow, learnsetFetchRequest: TutorLearnsetEntry.fetchRequest(forPokemonForm: form))
//            }
//        }
//        .listStyle(PlainListStyle())
//        .navigationTitle("Moves")
//    }

    init(form: PokemonForm, game: Game, initialLearnsetType learnsetType: LearnsetType) {
        self.form = form
        self.game = game
        self._selectedLearnsetType = .init(initialValue: learnsetType)
    }

}

struct PokemonLearnset_Previews: PreviewProvider {
    static var previews: some View {
        PokemonLearnset(form: StoredPokemon.generateCharizard().defaultForm, game: .sword, initialLearnsetType: .level)
            .modifier(Dependencies())
    }
}
