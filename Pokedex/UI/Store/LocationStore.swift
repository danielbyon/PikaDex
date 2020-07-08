//
//  LocationStore.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/11/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

// MARK: - Sample Data
extension Location {

    static func generateGalarRoute1() -> Location {
        generateLocation(withName: "Route 1", region: .galar, game: .sword)
    }

    static func generateLocation(withName name: String, region: Region, game: Game) -> Location {
        let moc = Dependencies.container.viewContext
        let fetchRequest = Location.fetchRequest(forName: name, region: region, game: game)
        let location = try! moc.fetch(fetchRequest).first!
        return location
    }

}
