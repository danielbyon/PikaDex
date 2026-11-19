//
//  PokemonLocations.swift
//  
//
//  Created by Daniel Byon on 11/5/22.
//

import PokedexUI
import SwiftUI

public struct PokemonLocations: View {

    let pokemonForm: PokemonDetailForm

    @Query private var locationPokemons: QueryResults<LocationPokemon>

    private var sections: [LocationSection] { locationPokemons.sections }

    fileprivate struct LocationSection {
        let location: Location
        var viewModels: [ViewModel]
    }

    public var body: some View {
        List {
            if locationPokemons.isEmpty {
                Text("No obtainable locations in Pokémon \(pokemonForm.game.title)")
                    .monospacedBody()
            } else {
                ForEach(sections) { section in
                    Section {
                        ForEach(section.viewModels) { viewModel in
                            BadgeCell(viewModel: viewModel)
                        }
                    } header: {
                        NavigationLink(value: Route.content(.location(section.location))) {
                            PokemonLocationSectionHeader(section.location.name)
                        }
                    }
                }
            }
        }
        .listStyle(.grouped)
        .navigationTitle("Locations")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                HomeButton()
            }
        }
        .onAppear {
            $locationPokemons.wrappedValue = .init(pokemonForm: pokemonForm)
        }
    }

    public init(pokemonForm: PokemonDetailForm) {
        self.pokemonForm = pokemonForm
    }

}

struct PokemonLocations_Previews: PreviewProvider {
    static var previews: some View {
        PokemonLocations(pokemonForm: .charizard)
    }
}

extension PokemonLocations.LocationSection: Identifiable {

    var id: String { location.name }

}

private struct ViewModel {

    let id: String
    let title: String
    let subtitle: String?
    let badge: Badge

    @MainActor
    init(locationPokemon: LocationPokemon) {
        let title = "\(locationPokemon.area): \(locationPokemon.encounterRateString)"
        let subtitle = locationPokemon.levelRangeWithDetail
        let badge = Badge(encounterRate: locationPokemon.encounterRate)
        self.title = title
        self.subtitle = subtitle
        self.badge = badge
        self.id = title + String(describing: subtitle) + badge.title
    }

}

extension ViewModel: Identifiable { }

private struct PokemonLocationSectionHeader: View {

    let title: String

    var body: some View {
        HStack {
            SectionHeader(title)
            Spacer()
            Image(systemName: "chevron.right")
                .monospacedBody()
        }
        .foregroundColor(.primary)
    }

    init(_ title: String) {
        self.title = title
    }

}

private extension BadgeCell {

    init(viewModel: ViewModel) {
        self.init(
            title: viewModel.title,
            subtitle: viewModel.subtitle,
            image: nil,
            badge: viewModel.badge)
    }

}

private extension Collection where Self.Element == LocationPokemon {

    @MainActor
    var sections: [PokemonLocations.LocationSection] {
        var sections: [PokemonLocations.LocationSection] = .init()
        self.forEach { element in
            if let index = sections.firstIndex(where: { $0.location == element.location }) {
                var section = sections[index]
                section.viewModels.append(.init(locationPokemon: element))
                sections[index] = section
            } else {
                sections.append(.init(location: element.location, viewModels: [.init(locationPokemon: element)]))
            }
        }
        return sections
    }

}
