//
//  PokemonListFilter.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/17/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct PokemonListFilter: View {

    private let game: Game
    private let viewModel: FilterablePokemonListViewModel

    @Environment(\.presentationMode) var presentationMode
    @State private var filterBy: Pokemon.Filter.FilterBy
    @State private var sortBy: Pokemon.Filter.SortBy
    @State private var sortOrder: Pokemon.Filter.SortOrder

    var body: some View {
        NavigationView {
            Form {
                Section(header: SectionHeader("Filter By")) {
                    ForEach(game.filterBys) { filterBy in
                        FilterCell(title: filterBy.title, isSelected: self.filterBy == filterBy)
                            .onTapGesture {
                                self.filterBy = filterBy
                        }
                    }
                }

                Section(header: SectionHeader("Sort By")) {
                    ForEach(Pokemon.Filter.SortBy.allCases) { sortBy in
                        FilterCell(title: sortBy.rawValue.capitalized, isSelected: self.sortBy == sortBy)
                            .onTapGesture {
                                self.sortBy = sortBy
                        }
                    }
                }

                Section(header: SectionHeader("Sort Order")) {
                    SegmentedControl(selectedSegment: $sortOrder)
                }
            }
            .listStyle(GroupedListStyle())
            .navigationTitle("Filter / Sort")
            .toolbar {
                ToolbarItem(placement: .destructiveAction) {
                    Button("Reset", action: resetFilter)
                }

                ToolbarItem(placement: .confirmationAction) {
                    DoneButton(action: dismiss)
                }
            }
            .onDisappear(perform: commitFilter)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    init(game: Game, viewModel: FilterablePokemonListViewModel) {
        self.game = game
        self.viewModel = viewModel
        self._filterBy = .init(initialValue: viewModel.filter.filterBy)
        self._sortBy = .init(initialValue: viewModel.filter.sortBy)
        self._sortOrder = .init(initialValue: viewModel.filter.sortOrder)
    }

    private func dismiss() {
        commitFilter()
        presentationMode.wrappedValue.dismiss()
    }

    private func resetFilter() {
        let filter = Pokemon.Filter.defaultFilter(forGame: game)
        filterBy = filter.filterBy
        sortBy = filter.sortBy
        sortOrder = filter.sortOrder
        dismiss()
    }

    private func commitFilter() {
        if viewModel.filter.filterBy != filterBy
            || viewModel.filter.sortBy != sortBy
            || viewModel.filter.sortOrder != sortOrder {
            viewModel.filter = .init(filterBy: filterBy, sortBy: sortBy, sortOrder: sortOrder)
        }
    }

}

struct PokemonListFilter_Previews: PreviewProvider {

    @State static var filter = Pokemon.Filter.defaultFilter(forGame: .x)

    static var previews: some View {
        PokemonListFilter(game: .x, viewModel: .init())
    }
}

private struct FilterCell: View {

    let title: String
    let isSelected: Bool

    var body: some View {
        HStack {
            Text(title)
                .monospacedBody()
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
            }
        }
        .contentShape(Rectangle())
    }

}
