//
//  PokemonColor+UIColor.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/18/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

#if os(iOS)

import UIKit

extension PokemonColor {

    public var uiColor: UIColor {
        switch self {
        case .black: return #colorLiteral(red: 0.173, green: 0.173, blue: 0.173, alpha: 1.0)
        case .blue: return #colorLiteral(red: 0.601, green: 0.859, blue: 0.939, alpha: 1.0)
        case .brown: return #colorLiteral(red: 0.79, green: 0.599, blue: 0.38, alpha: 1.0)
        case .gray: return #colorLiteral(red: 0.819, green: 0.82, blue: 0.881, alpha: 1.0)
        case .green: return #colorLiteral(red: 0.435, green: 0.824, blue: 0.36, alpha: 1.0)
        case .pink: return #colorLiteral(red: 0.946, green: 0.742, blue: 0.787, alpha: 1.0)
        case .purple: return #colorLiteral(red: 0.745, green: 0.518, blue: 0.764, alpha: 1.0)
        case .red: return #colorLiteral(red: 0.878, green: 0.525, blue: 0.51, alpha: 1)
        case .white: return .white
        case .yellow: return #colorLiteral(red: 1.0, green: 0.997, blue: 0.568, alpha: 1.0)
        }
    }

    // TODO: Cleanup once testing is done
    public var isDark: Bool {
        switch self {
        case .black:
            return true
        case .blue:
            return false
        case .brown:
            return false
        case .gray:
            return false
        case .green:
            return false
        case .pink:
            return false
        case .purple:
            return false
        case .red:
            return false
        case .white:
            return false
        case .yellow:
            return false
        }
    }

}

#endif
