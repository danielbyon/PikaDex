//
//  AbilityFilter.swift
//  
//
//  Created by Daniel Byon on 10/21/22.
//

import CoreData
import Foundation

public struct AbilityFilter: SearchableFilter {

    public typealias ResultType = StoredAbility

    public static var `default`: AbilityFilter {
        .init(game: .national)
    }

    public let game: Game
    public var query: SearchQuery

    public init(
        game: Game,
        query: SearchQuery = .empty
    ) {
        self.game = game
        self.query = query
    }

    public func makeFetchRequest(_ dataStore: DataStore) -> NSFetchRequest<StoredAbility> {
        let request: NSFetchRequest<StoredAbility> = StoredAbility.fetchRequest()
        var predicates: [NSPredicate] = []
        if let generation = game.metadata?.generation {
            predicates.append(NSPredicate(format: "\(#keyPath(StoredAbility.z_generationIntroduced)) <= %d", generation.rawValue))
        } else {
            assert(game.isNational)
        }

        if !query.isEmpty {
            switch query {
            case .contains(let string):
                predicates.append(.init(format: "\(#keyPath(StoredAbility.z_canonicalName)) CONTAINS %@", string.normalizedForSearch))
            case .exact(let string):
                predicates.append(.init(format: "\(#keyPath(StoredAbility.z_canonicalName)) == %@", string.normalizedForSearch))
            }
        }

        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(StoredAbility.z_name), ascending: true)]
        return request
    }

}
