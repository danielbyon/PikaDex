//
//  TimeOfDay.swift
//  Pokedex
//
//  Created by Daniel Byon on 3/11/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

public enum TimeOfDay: String, CaseIterable {
    case morning = "Morning"
    case day = "Day"
    case night = "Night"
}

extension TimeOfDay: Codable { }

extension TimeOfDay: Comparable {

    public static func < (lhs: TimeOfDay, rhs: TimeOfDay) -> Bool {
        TimeOfDay.allCases.firstIndex(of: lhs) ?? 0 < TimeOfDay.allCases.firstIndex(of: rhs) ?? 0
    }

}

extension TimeOfDay: Hashable { }
