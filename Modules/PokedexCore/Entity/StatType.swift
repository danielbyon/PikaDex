//
//  StatType.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/21/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

public enum StatType: String, Codable, Equatable, Hashable {

    case hp
    case attack
    case defense
    case specialAttack
    case specialDefense
    case speed

}
