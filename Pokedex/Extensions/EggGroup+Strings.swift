//
//  EggGroup+Strings.swift
//  Pokedex
//
//  Created by Daniel Byon on 1/24/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

extension EggGroup {

    var title: String {
        switch self {
        case .amorphous,
             .bug,
             .ditto,
             .dragon,
             .fairy,
             .field,
             .flying,
             .grass,
             .humanLike,
             .mineral,
             .monster,
             .undiscovered:
            return rawValue.capitalized
        case .water1:
            return "Water 1"
        case .water2:
            return "Water 2"
        case .water3:
            return "Water 3"
        }
    }

}
