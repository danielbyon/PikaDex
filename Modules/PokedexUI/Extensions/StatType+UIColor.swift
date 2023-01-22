//
//  StatType+UIColor.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/24/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import PokedexCore
import SwiftUI

extension StatType {

    public var uiColor: UIColor {
        switch self {
        case .hp:
            return .black
        case .attack:
            return #colorLiteral(red: 1.0, green: 0.661, blue: 0.431, alpha: 1.0)
        case .defense:
            return #colorLiteral(red: 0.998, green: 0.878, blue: 0.393, alpha: 1.0)
        case .speed:
            return #colorLiteral(red: 1.0, green: 0.545, blue: 0.7, alpha: 1.0)
        case .specialAttack:
            return #colorLiteral(red: 0.594, green: 0.718, blue: 0.982, alpha: 1.0)
        case .specialDefense:
            return #colorLiteral(red: 0.594, green: 0.869, blue: 0.516, alpha: 1.0)
        }
    }

}
