//
//  LocationPokemonsViewModel.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/29/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

final class LocationPokemonsViewModel {

    private(set) var sections: [LocationPokemonSection] = []

    let game: Game

    init(locationPokemons: [LocationPokemon], game: Game) {
        self.game = game

        var sections: [String: [LocationPokemon]] = [:]
        for item in Array(locationPokemons) {
            let sectionName = item.sectionName
            if var section = sections[sectionName] {
                section.append(item)
                sections[sectionName] = section
            } else {
                sections[sectionName] = [item]
            }
        }

        self.sections = sections.map { _, items in
            let subtitle: String
            if items[0].encounterCondition == "none" {
                subtitle = items[0].captureMethod.rawValue
            } else {
                subtitle = "\(items[0].captureMethod.rawValue) (\(items[0].encounterCondition))"
            }
            let viewModels = items
                .sorted {
                    if $0.encounterRate == $1.encounterRate {
                        return $0.pokemon.name < $1.pokemon.name
                    } else {
                        return $0.encounterRate > $1.encounterRate
                    }
            }
            .compactMap { LocationPokemonViewModel(locationPokemon: $0, game: game) }
            return LocationPokemonSection(
                title: items[0].area,
                subtitle: subtitle,
                detail: items[0].timeOfDay?.concatenatedRawValues,
                items: viewModels)
        }.sorted()
    }

}

private extension LocationPokemon {

    var subtitle: String { "\(captureMethod) (\(encounterRate.string))" }

    var sectionName: String {
        [area,
         captureMethod.rawValue,
         encounterCondition,
         timeOfDay?.concatenatedRawValues
            ].compactMap { $0 }
            .joined(separator: " ")
    }

}
