//
//  LocationPokemonSection.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/29/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

struct LocationPokemonSection {

    let title: String
    let subtitle: String
    let detail: String?
    let items: [LocationPokemonViewModel]

}

extension LocationPokemonSection: Comparable {

    static func < (lhs: LocationPokemonSection, rhs: LocationPokemonSection) -> Bool {
        if lhs.title == rhs.title {
            if lhs.subtitle == rhs.subtitle {
                return lhs.detail ?? "" < rhs.detail ?? ""
            } else {
                return lhs.subtitle < rhs.subtitle
            }
        } else {
            return lhs.title < rhs.title
        }
    }

}

extension LocationPokemonSection: Equatable {

    static func == (lhs: LocationPokemonSection, rhs: LocationPokemonSection) -> Bool {
        lhs.title == rhs.title
            && lhs.subtitle == rhs.subtitle
            && lhs.detail == rhs.detail
            && lhs.items == rhs.items
    }

}

extension LocationPokemonSection: Identifiable {

    var id: String { title + subtitle + (detail ?? "") }

}
