//
//  LocationPokemon+Strings.swift
//  
//
//  Created by Daniel Byon on 10/19/22.
//

import Foundation

extension LocationPokemon {

    public var encounterRateString: String {
        if encounterCondition == "none" {
            return captureMethod.rawValue + timeOfDaySuffix
        } else {
            return captureMethod.rawValue + " - \(encounterCondition)" + timeOfDaySuffix
        }
    }

    public var levelRangeWithDetail: String? {
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

    public var timeOfDaySuffix: String {
        guard let timeOfDay = timeOfDay,
              Set(timeOfDay) != Set(TimeOfDay.allCases) else { return "" }
        return " (\(timeOfDay.map { $0.rawValue }.joined(separator: ", ")))"
    }

}
