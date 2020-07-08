//
//  Location+Extensions.swift
//  Pokedex
//
//  Created by Daniel Byon on 3/11/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Fetch Requests
public extension Location {

    static func allFetchRequest(for game: Game) -> NSFetchRequest<Location> {
        let request: NSFetchRequest<Location> = Location.fetchRequest()
        request.predicate = NSPredicate(format: "z_game == %@", game.rawValue)
        commonConfigureRequest(request)
        return request
    }

    static func fetchRequest(forName name: String, region: Region, game: Game) -> NSFetchRequest<Location> {
        let request: NSFetchRequest<Location> = Location.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "z_game == %@ AND \(#keyPath(Location.z_name)) ==[cdn] %@ AND \(#keyPath(Location.z_region)) == %@", game.rawValue, name, region.rawValue)
        commonConfigureRequest(request)
        return request
    }

    static func fetchRequest(for pokemon: Pokemon, game: Game) -> NSFetchRequest<Location> {
        let request: NSFetchRequest<Location> = Location.fetchRequest()
        request.fetchBatchSize = DatabaseConstants.fetchBatchSize
        request.predicate = NSPredicate(format: "z_game == %@ AND locationPokemon.z_pokemon == %@", game.rawValue, pokemon)
        commonConfigureRequest(request)
        return request
    }

    private static func commonConfigureRequest(_ request: NSFetchRequest<Location>) {
        request.relationshipKeyPathsForPrefetching = [
            #keyPath(Location.z_maps)
        ]
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Location.i_nameIndex), ascending: true)]

    }

}

// MARK: - CanonicallyNamed
extension Location: CanonicallyNamed {

    var canonicalName: String { z_canonicalName ?? _missingString }

}

// MARK: - Identifiable
extension Location: Identifiable {

    public var id: String { name + region.rawValue }

}

// MARK: - Values
public extension Location {

    var game: Game {
        get { Game(rawValue: z_game!)! }
        set { z_game = newValue.rawValue }
    }

    var name: String {
        get { z_name! }
        set { z_name = newValue; z_canonicalName = newValue.normalizedForSearch }
    }

    var maps: [LocationMap] {
        get { (z_maps?.allObjects as? [LocationMap])?.sorted { $0.areaName < $1.areaName } ?? [] }
        set { z_maps = NSSet(array: newValue) }
    }

    var region: Region {
        get { Region(rawValue: z_region!)! }
        set { z_region = newValue.rawValue }
    }

}
