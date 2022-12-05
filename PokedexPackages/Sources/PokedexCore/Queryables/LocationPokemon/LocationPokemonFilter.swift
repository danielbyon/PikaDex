//
//  LocationPokemonFilter.swift
//  
//
//  Created by Daniel Byon on 10/19/22.
//

import CoreData
import Foundation

public struct LocationPokemonFilter: QueryFilter {

    public typealias ResultType = StoredLocationPokemon

    public static var `default`: LocationPokemonFilter {
        .init(predicate: NSPredicate(value: false))
    }

    private let predicate: NSPredicate

    public init(location: Location) {
        predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "\(#keyPath(StoredLocationPokemon.z_location.z_name)) == %@", location.name),
            NSPredicate(format: "\(#keyPath(StoredLocationPokemon.z_location.z_region)) == %@", location.region.rawValue),
            NSPredicate(format: "\(#keyPath(StoredLocationPokemon.z_game)) == %@", location.game.rawValue)
        ])
    }

    public init(pokemonForm: PokemonDetailForm) {
        predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "\(#keyPath(StoredLocationPokemon.z_pokemon.z_index)) == %d", pokemonForm.index),
            NSPredicate(format: "\(#keyPath(StoredLocationPokemon.z_game)) == %@", pokemonForm.game.rawValue)
        ])
    }

    private init(predicate: NSPredicate) {
        self.predicate = predicate
    }

    public func makeFetchRequest(_ dataStore: DataStore) -> NSFetchRequest<StoredLocationPokemon> {
        let request: NSFetchRequest<StoredLocationPokemon> = StoredLocationPokemon.fetchRequest()
        request.predicate = predicate
        request.relationshipKeyPathsForPrefetching = [
            #keyPath(StoredLocationPokemon.z_location),
            #keyPath(StoredLocationPokemon.z_pokemon),
            #keyPath(StoredLocationPokemon.z_pokemon.z_forms)
        ]
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(StoredLocationPokemon.z_location.z_name), ascending: true),
            NSSortDescriptor(key: #keyPath(StoredLocationPokemon.z_area), ascending: true),
            NSSortDescriptor(key: #keyPath(StoredLocationPokemon.z_captureMethod), ascending: true),
            NSSortDescriptor(key: #keyPath(StoredLocationPokemon.z_pokemon.z_name), ascending: true)
        ]
        return request
    }

}
