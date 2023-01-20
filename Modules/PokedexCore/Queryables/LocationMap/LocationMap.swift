//
//  LocationMap.swift
//  
//
//  Created by Daniel Byon on 10/19/22.
//

import Foundation

public struct LocationMap {

    public let areaName: String
    public let filename: String
    public let game: Game

    public init(result: StoredLocationMap) {
        areaName = result.areaName
        filename = result.filename
        game = result.location.game
    }

}

extension LocationMap: Codable { }

extension LocationMap: Comparable {

    public static func < (lhs: LocationMap, rhs: LocationMap) -> Bool {
        return lhs.areaName < rhs.areaName
    }

}

extension LocationMap: Hashable { }

extension LocationMap: Identifiable {

    public var id: String { areaName }

}
