//
//  Flavor+UIColor.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/23/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import UIKit

extension Flavor {

    var uiColor: UIColor {
        switch self {
        case .bitter:
            return #colorLiteral(red: 0.594, green: 0.869, blue: 0.516, alpha: 1.0)
        case .dry:
            return #colorLiteral(red: 0.594, green: 0.718, blue: 0.982, alpha: 1.0)
        case .sour:
            return #colorLiteral(red: 0.998, green: 0.878, blue: 0.393, alpha: 1.0)
        case .spicy:
            return #colorLiteral(red: 1.0, green: 0.661, blue: 0.431, alpha: 1.0)
        case .sweet:
            return #colorLiteral(red: 1.0, green: 0.545, blue: 0.7, alpha: 1.0)
        }
    }

}
