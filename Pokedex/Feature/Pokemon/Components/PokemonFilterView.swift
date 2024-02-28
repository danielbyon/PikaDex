//
//  PokemonFilterView.swift
//  
//
//  Created by Daniel Byon on 9/19/22.
//

import SwiftUI
import PokedexCore
import PokedexUI

public struct PokemonFilterView: View {

    @Binding var filter: PokemonFilter

    @Environment(\.presentationMode) var presentationMode

    let game: Game

    var pokedexes: [(title: String, pokedex: Pokedex)] {
        game.pokedexes.map { (title: $0.filterTitle, pokedex: $0) }
    }

    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(selection: $filter.pokedex) {
                        ForEach(pokedexes, id: \.title) { (title, pokedex) in
                            Text(title)
                                .tag(pokedex)
                        }
                    } label: {
                        EmptyView()
                    }
                    .pickerStyle(.inline)
                } header: {
                    SectionHeader("Filter By")
                }

                Section {
                    Picker(selection: $filter.sortBy) {
                        ForEach(PokemonFilter.SortBy.allCases, id: \.self) { sortBy in
                            Text(sortBy.rawValue.capitalized)
                                .tag(sortBy)
                        }
                    } label: {
                        EmptyView()
                    }
                    .pickerStyle(.inline)
                } header: {
                    SectionHeader("Sort By")
                }

                Section {
                    SegmentedControl(selectedSegment: $filter.sortOrder)
                } header: {
                    SectionHeader("Sort Order")
                }
            }
            .listStyle(.grouped)
            .navigationTitle("Filter / Sort")
            .toolbar {
                ToolbarItem(placement: .destructiveAction) {
                    Button("Reset", action: resetFilter)
                }

                ToolbarItem(placement: .confirmationAction) {
                    DoneButton(action: dismiss)
                }
            }
        }
    }

    public init(game: Game, filter: Binding<PokemonFilter>) {
        self.game = game
        self._filter = filter
    }

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

    private func resetFilter() {
        filter = .default(for: game)
        dismiss()
    }

}

private extension Pokedex {

    var filterTitle: String {
        switch self {
        case .national:
            return "National"
        case .kanto,
                .johto,
                .hoenn,
                .sinnoh,
                .newJohto,
                .unova,
                .newUnova,
                .centralKalos,
                .coastalKalos,
                .mountainKalos,
                .newHoenn,
                .alola,
                .melemele,
                .akala,
                .ulaula,
                .poni,
                .ultraAlola,
                .ultraMelemele,
                .ultraAkala,
                .ultraUlaula,
                .ultraPoni,
                .letsGoKanto,
                .galar,
                .isleOfArmor,
                .crownTundra,
                .hisui,
                .paldea,
                .kitakami,
                .blueberry:
            return "Regional (\(title))"
        }
    }

}

struct ListPokemonFilterView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewContainer {
            PokemonFilterView(game: .national, filter: .constant(.init(game: .national, pokedex: .national)))
        }
    }
}
