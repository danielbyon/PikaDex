//
//  EncounterRate+Strings.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/19/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

extension EncounterRate {

    var string: String {
        switch self {
        case .percent(let percent):
            return "\(percent)%"
        case .rarity(let rarity):
            return rarity.rawValue.capitalized
        case .unknown:
            return "Unknown"
        }
    }

}
