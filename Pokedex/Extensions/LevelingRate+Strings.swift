//
//  LevelingRate+Strings.swift
//  Pokedex
//
//  Created by Daniel Byon on 1/24/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

extension LevelingRate {

    var title: String {
        switch self {
        case .erratic: return "Erratic"
        case .fast: return "Fast"
        case .fluctuating: return "Fluctuating"
        case .mediumFast: return "Medium Fast"
        case .mediumSlow: return "Medium Slow"
        case .slow: return "Slow"
        }
    }

}
