//
//  StatType+String.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/24/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

extension StatType {

    public var title: String {
        switch self {
        case .hp:
            return "HP"
        case .attack:
            return "ATK"
        case .defense:
            return "DEF"
        case .speed:
            return "SPD"
        case .specialAttack:
            return "SP. ATK"
        case .specialDefense:
            return "SP. DEF"
        }
    }

}
