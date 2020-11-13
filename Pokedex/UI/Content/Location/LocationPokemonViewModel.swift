//
//  LocationPokemonViewModel.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/29/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct LocationPokemonViewModel {

    let title: String
    let subtitle: String?
    let badge: Badge
    let image: UIImage?
    let destination: PokemonDetail

    init?(locationPokemon: LocationPokemon, game: Game) {
        let pokemon = locationPokemon.pokemon
        let form = pokemon.defaultForm
        self.title = pokemon.name
        if locationPokemon.levelLow < 0 {
            let count = abs(locationPokemon.levelLow)
            self.subtitle = String(repeating: "⭐︎", count: count)
        } else if locationPokemon.levelLow > 0 {
            var subtitle = "Lv. \(locationPokemon.levelLow)"
            if let levelHigh = locationPokemon.levelHigh {
                subtitle += "-\(levelHigh)"
            }
            if let detail = locationPokemon.detail {
                subtitle += " (\(detail))"
            }
            self.subtitle = subtitle
        } else {
            self.subtitle = locationPokemon.detail
        }
        self.badge = Badge(encounterRate: locationPokemon.encounterRate)
        self.image = UIImage(named: form.spriteName)
        self.destination = PokemonDetail(pokemon: pokemon, game: game)
    }

}

extension LocationPokemonViewModel: Comparable {

    static func < (lhs: LocationPokemonViewModel, rhs: LocationPokemonViewModel) -> Bool {
        if lhs.title == rhs.title {
            return lhs.subtitle ?? "" < rhs.subtitle ?? ""
        } else {
            return lhs.title < rhs.title
        }
    }

}

extension LocationPokemonViewModel: Equatable {

    static func == (lhs: LocationPokemonViewModel, rhs: LocationPokemonViewModel) -> Bool {
        lhs.title == rhs.title
            && lhs.subtitle == rhs.subtitle
    }

}

extension LocationPokemonViewModel: Identifiable {

    var id: String { title + (subtitle ?? "") + badge.title }

}
