//
//  LocationMap+Extension.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/1/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Values
public extension LocationMap {

    var areaName: String {
        get { z_areaName! }
        set { z_areaName = newValue }
    }

    var filename: String {
        get { z_filename! }
        set { z_filename = newValue }
    }

    var location: Location {
        get { z_location! }
        set { z_location = newValue }
    }

}

// MARK: Identifiable
extension LocationMap: Identifiable {

    public var id: String { location.name + location.game.rawValue + areaName + filename }

}
