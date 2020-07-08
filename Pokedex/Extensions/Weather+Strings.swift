//
//  Weather+Strings.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/20/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

extension Weather {

    var title: String {
        switch self {
        case .blizzard: return "Blizzard"
        case .clear: return "Clear"
        case .cloudy: return "Cloudy"
        case .fog: return "Fog"
        case .harshSunlight: return "Harsh Sunlight"
        case .rain: return "Rain"
        case .snow: return "Snow"
        case .thunderstorm: return "Thunderstorm"
        }
    }

}
