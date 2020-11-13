//
//  SelectTeamMemberMove.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/21/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct SelectTeamMemberMove: View {

    let pokemonForm: PokemonForm
    let game: Game
    let onSelect: (Move) -> Void

    @FetchRequest private var levelLearnset: FetchedResults<LevelLearnsetEntry>
    @FetchRequest private var machineLearnset: FetchedResults<MachineLearnsetEntry>
    @FetchRequest private var breedLearnset: FetchedResults<BreedLearnsetEntry>
    @FetchRequest private var tutorLearnset: FetchedResults<TutorLearnsetEntry>
    @FetchRequest private var allMoves: FetchedResults<Move>
    @State private var showMovesByPokemon = true
    @State private var selectedSegment: String

    private var levelEntries: [PokemonLearnsetViewModel] { levelLearnset.map { PokemonLearnsetViewModel(learnsetEntry: $0) } }
    private var machineEntries: [PokemonLearnsetViewModel] { machineLearnset.map { PokemonLearnsetViewModel(learnsetEntry: $0) } }
    private var breedEntries: [PokemonLearnsetViewModel] { breedLearnset.map { PokemonLearnsetViewModel(learnsetEntry: $0) } }
    private var tutorEntries: [PokemonLearnsetViewModel] { tutorLearnset.map { PokemonLearnsetViewModel(learnsetEntry: $0) } }

    var body: some View {
        List {
            Section {
                Picker("", selection: $selectedSegment) {
                    Text("\(pokemonForm.pokemon.name)-specific")
                        .tag("\(pokemonForm.pokemon.name)-specific")
                    Text("All Moves")
                        .tag("All Moves")
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            if showMovesByPokemon {
                if !levelLearnset.isEmpty {
                    Section(header: SectionHeader("By Level")) {
                        ForEach(levelEntries) { entry in
                            PokemonLearnsetGroupCell(move: entry.move, detailText: entry.detailText, game: self.game).onTapGesture {
                                self.onSelect(entry.move)
                            }
                        }
                    }
                }

                if !machineLearnset.isEmpty {
                    Section(header: SectionHeader("By Machine")) {
                        ForEach(machineEntries) { entry in
                            PokemonLearnsetGroupCell(move: entry.move, detailText: entry.detailText, game: self.game).onTapGesture {
                                self.onSelect(entry.move)
                            }
                        }
                    }
                }

                if !breedLearnset.isEmpty {
                    Section(header: SectionHeader("By Breeding")) {
                        ForEach(breedEntries) { entry in
                            PokemonLearnsetGroupCell(move: entry.move, detailText: entry.detailText, game: self.game).onTapGesture {
                                self.onSelect(entry.move)
                            }
                        }
                    }
                }

                if !tutorLearnset.isEmpty {
                    Section(header: SectionHeader("By Tutoring")) {
                        ForEach(tutorEntries) { entry in
                            PokemonLearnsetGroupCell(move: entry.move, detailText: entry.detailText, game: self.game).onTapGesture {
                                self.onSelect(entry.move)
                            }
                        }
                    }
                }
            } else {
                ForEach(allMoves) { move in
                    MoveCell(move: move, game: self.game).onTapGesture {
                        self.onSelect(move)
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Select Move")
    }

    init(pokemonForm: PokemonForm, game: Game, onSelect: @escaping (Move) -> Void) {
        self.pokemonForm = pokemonForm
        self.game = game
        self.onSelect = onSelect
        self._levelLearnset = .init(fetchRequest: LevelLearnsetEntry.fetchRequest(forPokemonForm: pokemonForm))
        self._machineLearnset = .init(fetchRequest: MachineLearnsetEntry.fetchRequest(forPokemonForm: pokemonForm))
        self._breedLearnset = .init(fetchRequest: BreedLearnsetEntry.fetchRequest(forPokemonForm: pokemonForm))
        self._tutorLearnset = .init(fetchRequest: TutorLearnsetEntry.fetchRequest(forPokemonForm: pokemonForm))
        self._allMoves = .init(fetchRequest: Move.allFetchRequest(for: game))
        self._selectedSegment = .init(initialValue: "\(pokemonForm.pokemon.name)-specific")
    }

}

struct SelectTeamMemberMove_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SelectTeamMemberMove(pokemonForm: Pokemon.generateCharizard(game: .sword).defaultForm, game: .sword, onSelect: { _ in })
        }
        .injectDependencies()
    }
}
