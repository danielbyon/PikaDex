//
//  LocationAreaViewModel.swift
//  
//
//  Created by Daniel Byon on 10/19/22.
//

import PokedexCore
import SwiftUI

final class LocationAreaViewModel: ObservableObject {

    let sections: [Section]

    struct Section {
        let title: String
        let rows: [Row]
    }

    struct Row {
        let pokemon: Pokemon
        let items: [Item]
    }

    struct Item {

        let title: String
        let subtitle: String?
        let encounterRate: EncounterRate

        init(locationPokemon: LocationPokemon) {
            self.title = locationPokemon.encounterRateString
            self.subtitle = locationPokemon.levelRangeWithDetail
            self.encounterRate = locationPokemon.encounterRate
        }

    }

    init(
        location: Location,
        locationPokemons: QueryResults<LocationPokemon>
    ) {
        var transforms: [String: [Pokemon: [LocationPokemon]]] = [:]
        locationPokemons.forEach { locationPokemon in
            let area = locationPokemon.area
            let pokemon = locationPokemon.pokemon
            if var existingArea = transforms[area] {
                if var existingPokemon = existingArea[pokemon] {
                    existingPokemon.append(locationPokemon)
                    existingArea[pokemon] = existingPokemon
                } else {
                    existingArea[pokemon] = [locationPokemon]
                }
                transforms[area] = existingArea
            } else {
                transforms[area] = [locationPokemon.pokemon: [locationPokemon]]
            }
        }

        self.sections = transforms
            .map { area, areaPokemon in
                let rows: [Row] = areaPokemon.map { pokemon, locationPokemons in
                    let items = locationPokemons
                        .map { Item(locationPokemon: $0) }
                        .sorted()
                    return Row(pokemon: pokemon, items: items)
                }
                    .sorted()

                let title = "\(area) Area Pokémon"
                return Section(title: title, rows: rows)
            }
            .sorted()
    }

}

extension LocationAreaViewModel.Section: Comparable {

    static func < (lhs: LocationAreaViewModel.Section, rhs: LocationAreaViewModel.Section) -> Bool {
        return lhs.title < rhs.title
    }

}

extension LocationAreaViewModel.Section: Hashable { }

extension LocationAreaViewModel.Section: Identifiable {

    var id: String { title + rows.map { $0.id }.joined() }

}

extension LocationAreaViewModel.Row: Comparable {

    static func < (lhs: LocationAreaViewModel.Row, rhs: LocationAreaViewModel.Row) -> Bool {
        return lhs.pokemon.index < rhs.pokemon.index
    }

}

extension LocationAreaViewModel.Row: Hashable { }

extension LocationAreaViewModel.Row: Identifiable {

    var id: String { pokemon.name + items.map { $0.id }.joined() }

}

extension LocationAreaViewModel.Item: Comparable {

    static func < (lhs: LocationAreaViewModel.Item, rhs: LocationAreaViewModel.Item) -> Bool {
        if lhs.title == rhs.title {
            return lhs.subtitle ?? "" < rhs.subtitle ?? ""
        } else {
            return lhs.title < rhs.title
        }
    }

}

extension LocationAreaViewModel.Item: Hashable { }

extension LocationAreaViewModel.Item: Identifiable {

    var id: String { title + (subtitle ?? "") }

}
