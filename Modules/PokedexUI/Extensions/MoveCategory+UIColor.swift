//
//  MoveCategory+UIColor.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/15/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

#if os(iOS)

import UIKit

extension MoveCategory {

    public var uiColor: UIColor {
        switch self {
        case .physical: return #colorLiteral(red: 0.787, green: 0.124, blue: 0.03, alpha: 1.0)
        case .status: return #colorLiteral(red: 0.549, green: 0.533, blue: 0.55, alpha: 1.0)
        case .special: return #colorLiteral(red: 0.31, green: 0.345, blue: 0.444, alpha: 1.0)
        case .varies: return #colorLiteral(red: 153.0 / 255.0, green: 153.0 / 255.0, blue: 153.0 / 255.0, alpha: 1.0)
        }
    }

}

#endif
