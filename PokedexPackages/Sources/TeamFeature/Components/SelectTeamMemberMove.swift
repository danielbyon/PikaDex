//
//  SelectTeamMemberMove.swift
//  
//
//  Created by Daniel Byon on 11/1/22.
//

import PokedexUI
import SwiftUI

struct SelectTeamMemberMove<ViewFactory: TeamViewFactory>: View {

    let pokemonForm: PokemonDetailForm
    let currentMove: Move?
    let viewFactory: ViewFactory
    let onSelect: (Move) -> Void

    @Environment(\.dismiss) private var dismiss
    @Query private var allMoves: QueryResults<Move>
    @Query private var levelEntries: QueryResults<LearnsetEntry>
    @Query private var machineEntries: QueryResults<LearnsetEntry>
    @Query private var breedingEntries: QueryResults<LearnsetEntry>
    @Query private var tutoringEntries: QueryResults<LearnsetEntry>
    @State private var showMovesByPokemon = true

    private var query: Binding<String> {
        .init {
            $levelEntries.query.wrappedValue
        } set: { newValue in
            $allMoves.query.wrappedValue = newValue
            $levelEntries.query.wrappedValue = newValue
            $machineEntries.query.wrappedValue = newValue
            $breedingEntries.query.wrappedValue = newValue
            $tutoringEntries.query.wrappedValue = newValue
        }

    }

    var body: some View {
        List {
            if showMovesByPokemon {
                if !levelEntries.isEmpty {
                    makeLearnsetSection(title: "By Level", entries: levelEntries)
                }
                if !machineEntries.isEmpty {
                    makeLearnsetSection(title: "By Machine", entries: machineEntries)
                }
                if !breedingEntries.isEmpty {
                    makeLearnsetSection(title: "By Breeding", entries: breedingEntries)
                }
                if !tutoringEntries.isEmpty {
                    makeLearnsetSection(title: "By Tutoring", entries: tutoringEntries)
                }
            } else {
                ForEach(allMoves, id: \.self) { move in
                    MoveCell(move: move)
                        .onTapGesture {
                            onSelect(move)
                            dismiss()
                        }
                }
            }
        }
        .listStyle(.grouped)
        .navigationTitle("Select Move")
        .searchable(text: query, placement: .navigationBarDrawer(displayMode: .always))
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Picker("", selection: $showMovesByPokemon) {
                    Text("\(pokemonForm.pokemonName)-specific")
                        .tag(true)
                    Text("All Moves")
                        .tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .onAppear {
            $allMoves.wrappedValue = .init(game: pokemonForm.game)
            $levelEntries.wrappedValue = .level(pokemonForm: pokemonForm)
            $machineEntries.wrappedValue = .machine(pokemonForm: pokemonForm)
            $breedingEntries.wrappedValue = .breeding(pokemonForm: pokemonForm)
            $tutoringEntries.wrappedValue = .tutoring(pokemonForm: pokemonForm)
        }
    }

    private func makeLearnsetSection(
        title: String,
        entries: QueryResults<LearnsetEntry>
    ) -> some View {
        Section {
            ForEach(entries) { entry in
                viewFactory.makeLearnsetCell(
                    move: entry.move,
                    detailText: entry.detailText,
                    game: entry.game
                )
            }
        } header: {
            SectionHeader(title)
        }
    }

}

struct SelectTeamMemberMove_Previews: PreviewProvider {
    static var previews: some View {
        SelectTeamMemberMove(
            pokemonForm: .charizard,
            currentMove: nil,
            viewFactory: MockTeamViewFactory(),
            onSelect: { _ in }
        )
    }
}
