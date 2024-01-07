//
//  PokemonLearnsetView.swift
//  
//
//  Created by Daniel Byon on 10/13/22.
//

import PokedexUI
import SwiftUI

public struct PokemonLearnsetView: View {

    @Query private var entries: QueryResults<LearnsetEntry>
    @State private var selectedLearnsetType: LearnsetType = .level

    let form: PokemonDetailForm
    let game: Game

    private var title: String { selectedLearnsetType.rawValue }

    public var body: some View {
        VStack {
            SegmentedControl(selectedSegment: $selectedLearnsetType, segments: LearnsetType.allCases(for: game))
                .padding(.horizontal)

            List {
                if !entries.isEmpty {
                    ForEach(entries) { entry in
                        NavigationLink(value: Route.content(.move(entry.move))) {
                            LearnsetCell(move: entry.move, detailText: entry.detailText, game: self.game)
                        }
                    }
                } else {
                    Text("This Pokémon learns no moves by \(title).")
                        .monospacedBody()
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Moves")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                HomeButton()
            }
        }
        .onAppear {
            updateQueryFilter(learnsetType: selectedLearnsetType)
        }
        .onChange(of: selectedLearnsetType) { _, newLearnsetType in
            updateQueryFilter(learnsetType: newLearnsetType)
        }
    }

    public init(form: PokemonDetailForm, game: Game, learnsetType: LearnsetType) {
        self.form = form
        self.game = game
        _selectedLearnsetType = .init(initialValue: learnsetType)
    }

    private func updateQueryFilter(learnsetType: LearnsetType) {
        switch selectedLearnsetType {
        case .level:
            $entries.wrappedValue = LearnsetEntryFilter.level(pokemonForm: form)
        case .machine:
            $entries.wrappedValue = LearnsetEntryFilter.machine(pokemonForm: form)
        case .breeding:
            $entries.wrappedValue = LearnsetEntryFilter.breeding(pokemonForm: form)
        case .tutoring:
            $entries.wrappedValue = LearnsetEntryFilter.tutoring(pokemonForm: form)
        }
    }

}

struct PokemonLearnsetView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonLearnsetView(form: .charizard, game: .sword, learnsetType: .level)
    }
}
