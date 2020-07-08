//
//  PokemonLocations.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/20/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct PokemonLocations: View {

    let pokemon: Pokemon
    let game: Game

    @FetchRequest var locationPokemons: FetchedResults<LocationPokemon>

    private var locations: [Location] {
        locationPokemons
            .uniqingValues { $0.location == $1.location }
            .map { $0.location }
    }

    private var sections: [LocationSection] { locationPokemons.sections }

    fileprivate struct LocationSection {
        let location: Location
        var viewModels: [ViewModel]
    }

    var body: some View {
        List {
            if !locationPokemons.isEmpty {
                ForEach(sections) { section in
                    Section(header: NavigationLink(destination: LocationDetail(location: section.location, game: self.game).injectDependencies(), label: {
                        PokemonLocationSectionHeader(section.location.name)
                    })) {
                        ForEach(section.viewModels) { viewModel in
                            BadgeCell(viewModel: viewModel)
                        }
                    }
                }
            } else {
                Text("No locations in Pokémon \(game.title)")
                    .monospacedBody()
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Locations")
    }

    init(pokemon: Pokemon, game: Game) {
        self.pokemon = pokemon
        self.game = game
        self._locationPokemons = .init(fetchRequest: LocationPokemon.fetchRequest(for: pokemon, game: game))
    }

}

struct PokemonLocations_Previews: PreviewProvider {
    static var previews: some View {
        PokemonLocations(pokemon: Pokemon.generate(withName: "Caterpie", game: .fireRed), game: .fireRed)
    }
}

extension PokemonLocations.LocationSection: Identifiable {

    var id: String { location.id }

}

private struct ViewModel {

    let title: String
    let subtitle: String?
    let badge: Badge

    init(locationPokemon: LocationPokemon) {
        self.title = "\(locationPokemon.area): \(locationPokemon.encounterRateString)"
        self.subtitle = locationPokemon.levelRangeWithDetail
        self.badge = Badge(encounterRate: locationPokemon.encounterRate)
    }

}

extension ViewModel: Identifiable {

    var id: String { title + String(describing: subtitle) + badge.title }

}

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
