//
//  Region.swift
//  Pokedex
//
//  Created by Daniel Byon on 3/11/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

public enum Region: String, CaseIterable {
    case kanto
    case johto
    case hoenn
    case seviiIslands = "sevii-islands"
    case sinnoh
    case unova
    case kalos
    case alola
    case galar
}

extension Region {

    var index: Int {
        switch self {
        case .kanto:
            return 0
        case .johto:
            return 1
        case .hoenn:
            return 2
        case .seviiIslands:
            return 3
        case .sinnoh:
            return 4
        case .unova:
            return 5
        case .kalos:
            return 6
        case .alola:
            return 7
        case .galar:
            return 8
        }
    }

}

extension Region: Comparable {

    public static func < (lhs: Region, rhs: Region) -> Bool {
        lhs.index < rhs.index
    }

}

extension Region: Equatable {

    public static func == (lhs: Region, rhs: Region) -> Bool {
        lhs.index == rhs.index
    }

}
