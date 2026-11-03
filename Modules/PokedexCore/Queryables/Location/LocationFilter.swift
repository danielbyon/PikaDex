//
//  LocationFilter.swift
//  
//
//  Created by Daniel Byon on 10/17/22.
//

import CoreData
import Foundation

public struct LocationFilter: SearchableFilter {

    public typealias ResultType = StoredLocation

    public static var `default`: LocationFilter {
        .init(game: .national)
    }

    private let predicate: NSPredicate
    public var query: SearchQuery

    public init(
        game: Game,
        query: SearchQuery = .empty
    ) {
        self.predicate = NSPredicate(format: "z_game == %@", game.rawValue)
        self.query = query
    }

    public init(
        locationName: String,
        region: Region,
        game: Game,
        query: SearchQuery = .empty
    ) {
        self.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "\(#keyPath(StoredLocation.z_game)) == %@", game.rawValue),
            NSPredicate(format: "\(#keyPath(StoredLocation.z_name)) ==[cdn] %@", locationName),
            NSPredicate(format: "\(#keyPath(StoredLocation.z_region)) == %@", region.rawValue)
        ])
        self.query = query
    }

    public init(
        pokemonName: String,
        game: Game,
        query: SearchQuery = .empty
    ) {
        self.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "\(#keyPath(StoredLocation.z_game)) == %@", game.rawValue),
            NSPredicate(format: "locationPokemon.z_pokemon == %@", pokemonName)
        ])
        self.query = query
    }

    public func makeFetchRequest() -> NSFetchRequest<StoredLocation> {
        let request: NSFetchRequest<StoredLocation> = StoredLocation.fetchRequest() as NSFetchRequest<StoredLocation>
        var predicates = [predicate]

        if !query.isEmpty {
            switch query {
            case .contains(let string):
                predicates.append(.init(format: "\(#keyPath(StoredLocation.z_canonicalName)) CONTAINS %@", string.normalizedForSearch))
            case .exact(let string):
                predicates.append(.init(format: "\(#keyPath(StoredLocation.z_canonicalName)) == %@", string.normalizedForSearch))
            }
        }

        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.relationshipKeyPathsForPrefetching = [
            #keyPath(StoredLocation.z_maps)
        ]
        request.fetchBatchSize = DatabaseConstants.fetchBatchSize
//        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(StoredLocation.i_nameIndex), ascending: true)]
        return request
    }

}
