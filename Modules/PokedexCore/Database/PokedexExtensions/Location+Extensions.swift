//
//  StoredLocation+Extensions.swift
//  Pokedex
//
//  Created by Daniel Byon on 3/11/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Fetch Requests
public extension StoredLocation {

    static func allFetchRequest(for game: Game) -> NSFetchRequest<StoredLocation> {
        let request: NSFetchRequest<StoredLocation> = StoredLocation.fetchRequest()
        request.predicate = NSPredicate(format: "z_game == %@", game.rawValue)
        commonConfigureRequest(request)
        return request
    }

    static func fetchRequest(forName name: String, region: Region, game: Game) -> NSFetchRequest<StoredLocation> {
        let request: NSFetchRequest<StoredLocation> = StoredLocation.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "z_game == %@ AND \(#keyPath(StoredLocation.z_name)) ==[cdn] %@ AND \(#keyPath(StoredLocation.z_region)) == %@", game.rawValue, name, region.rawValue)
        commonConfigureRequest(request)
        return request
    }

    static func fetchRequest(for pokemon: StoredPokemon, game: Game) -> NSFetchRequest<StoredLocation> {
        let request: NSFetchRequest<StoredLocation> = StoredLocation.fetchRequest()
        request.fetchBatchSize = DatabaseConstants.fetchBatchSize
        request.predicate = NSPredicate(format: "z_game == %@ AND locationPokemon.z_pokemon == %@", game.rawValue, pokemon)
        commonConfigureRequest(request)
        return request
    }

    private static func commonConfigureRequest(_ request: NSFetchRequest<StoredLocation>) {
        request.relationshipKeyPathsForPrefetching = [
            #keyPath(StoredLocation.z_maps)
        ]
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(StoredLocation.i_nameIndex), ascending: true)]

    }

}

// MARK: - CanonicallyNamed
extension StoredLocation: CanonicallyNamed {

    public var canonicalName: String { z_canonicalName ?? _missingString }

}

//// MARK: - Identifiable
//extension StoredLocation: Identifiable {
//
//    public var id: String { name + region.rawValue }
//
//}

// MARK: - Values
public extension StoredLocation {

    var bulbapediaURL: URL? {
        get {
            guard let z_bulbapediaURL else { return nil }
            return URL(string: z_bulbapediaURL)
        }
        set { z_bulbapediaURL = newValue?.absoluteString }
    }

    var game: Game {
        get { Game(rawValue: z_game!)! }
        set { z_game = newValue.rawValue }
    }

    var name: String {
        get { z_name! }
        set { z_name = newValue; z_canonicalName = newValue.normalizedForSearch }
    }

    var maps: [StoredLocationMap] {
        get { (z_maps?.allObjects as? [StoredLocationMap])?.sorted { $0.areaName < $1.areaName } ?? [] }
        set { z_maps = NSSet(array: newValue) }
    }

    var pokemonDBURL: URL? {
        get {
            guard let z_pokemonDBURL else { return nil }
            return URL(string: z_pokemonDBURL)
        }
        set { z_pokemonDBURL = newValue?.absoluteString }
    }

    var region: Region {
        get { Region(rawValue: z_region!)! }
        set { z_region = newValue.rawValue }
    }

}
