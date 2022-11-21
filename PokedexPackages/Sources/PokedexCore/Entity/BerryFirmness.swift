//
//  BerryFirmness.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/28/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

public enum BerryFirmness: String {

    case verySoft
    case soft
    case hard
    case veryHard
    case superHard

}

extension BerryFirmness: Codable { }

extension BerryFirmness: Hashable { }
