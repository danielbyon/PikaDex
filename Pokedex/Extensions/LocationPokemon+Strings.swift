//
//  LocationPokemon+Strings.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/20/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

extension LocationPokemon {

    var encounterRateString: String {
        if encounterCondition == "none" {
            return captureMethod.rawValue + timeOfDaySuffix
        } else {
            return captureMethod.rawValue + " - \(encounterCondition)" + timeOfDaySuffix
        }
    }

    var levelRangeWithDetail: String? {
        if levelLow < 0 {
            let count = abs(levelLow)
            return String(repeating: "⭐︎", count: count)
        } else if levelLow > 0 {
            return "Lv. \(levelLow)"
                + (levelHigh != nil ? "-\(levelHigh!)" : "")
                + (detail != nil ? " (\(detail!))" : "")
        } else {
            return detail
        }
    }

    var timeOfDaySuffix: String {
        guard let timeOfDay = timeOfDay,
            Set(timeOfDay) != Set(TimeOfDay.allCases) else { return "" }
        return " (\(timeOfDay.map { $0.rawValue }.joined(separator: ", ")))"
    }

}

extension Array where Self.Element == TimeOfDay {

    var concatenatedRawValues: String {
        map { $0.rawValue }.joined(separator: ", ")
    }

}
