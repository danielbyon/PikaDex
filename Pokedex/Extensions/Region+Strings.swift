//
//  Region+Strings.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/14/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

extension Region {

    var name: String {
        switch self {
        case .kanto,
             .johto,
             .hoenn,
             .sinnoh,
             .unova,
             .kalos,
             .alola,
             .galar:
            return rawValue.capitalized
        case .seviiIslands:
            return "Sevii Islands"
        }
    }

}
