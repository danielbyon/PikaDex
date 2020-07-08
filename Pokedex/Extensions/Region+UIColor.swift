//
//  Region+UIColor.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/14/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import UIKit

extension Region {

    var color: UIColor {
        switch self {
        case .kanto:
            return #colorLiteral(red: 0.423, green: 0.745, blue: 0.0, alpha: 1.0)
        case .johto:
            return #colorLiteral(red: 0.798, green: 0.756, blue: 0.0, alpha: 1.0)
        case .hoenn:
            return #colorLiteral(red: 0.241, green: 0.768, blue: 0.667, alpha: 1.0)
        case .seviiIslands:
            return #colorLiteral(red: 0.0, green: 0.815, blue: 0.548, alpha: 1.0)
        case .sinnoh:
            return #colorLiteral(red: 0.588, green: 0.438, blue: 0.653, alpha: 1.0)
        case .unova:
            return #colorLiteral(red: 0.329, green: 0.689, blue: 0.822, alpha: 1.0)
        case .kalos:
            return #colorLiteral(red: 0.869, green: 0.0, blue: 0.301, alpha: 1.0)
        case .alola:
            return #colorLiteral(red: 0.93, green: 0.309, blue: 0.203, alpha: 1.0)
        case .galar:
            return #colorLiteral(red: 0.733, green: 0.146, blue: 0.638, alpha: 1.0)
        }
    }

    var lightColor: UIColor {
        switch self {
        case .kanto:
            return #colorLiteral(red: 0.631, green: 0.837, blue: 0.357, alpha: 1.0)
        case .johto:
            return #colorLiteral(red: 0.865, green: 0.842, blue: 0.403, alpha: 1.0)
        case .hoenn:
            return #colorLiteral(red: 0.543, green: 0.852, blue: 0.782, alpha: 1.0)
        case .seviiIslands:
            return #colorLiteral(red: 0.41, green: 0.935, blue: 0.723, alpha: 1.0)
        case .sinnoh:
            return #colorLiteral(red: 0.734, green: 0.634, blue: 0.774, alpha: 1.0)
        case .unova:
            return #colorLiteral(red: 0.579, green: 0.797, blue: 0.885, alpha: 1.0)
        case .kalos:
            return #colorLiteral(red: 0.934, green: 0.332, blue: 0.551, alpha: 1.0)
        case .alola:
            return #colorLiteral(red: 0.963, green: 0.562, blue: 0.496, alpha: 1.0)
        case .galar:
            return #colorLiteral(red: 0.838, green: 0.468, blue: 0.768, alpha: 1.0)
        }
    }

}
