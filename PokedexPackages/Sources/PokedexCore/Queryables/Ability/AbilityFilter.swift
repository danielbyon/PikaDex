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
    public var query: String

    public init(
        game: Game,
        query: String = ""
    ) {
        self.game = game
        self.query = query
    }

    public func makeFetchRequest(_ dataStore: DataStore) -> NSFetchRequest<StoredAbility> {
        let request: NSFetchRequest<StoredAbility> = StoredAbility.fetchRequest()
        var predicates = [NSPredicate(format: "\(#keyPath(StoredAbility.z_generationIntroduced)) <= %d", game.generation.rawValue)]
        if !query.isEmpty {
            predicates.append(.init(format: "\(#keyPath(StoredAbility.z_canonicalName)) CONTAINS[cd] %@", query))
        }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(StoredAbility.z_name), ascending: true)]
        return request
    }

}
