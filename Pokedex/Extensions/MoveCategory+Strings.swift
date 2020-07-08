//
//  MoveCategory+Strings.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/15/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import Foundation

extension MoveCategory {

    var title: String {
        switch self {
        case .physical: return "Physical"
        case .status: return "Status"
        case .special: return "Special"
        case .varies: return "Varies"
        }
    }

}
