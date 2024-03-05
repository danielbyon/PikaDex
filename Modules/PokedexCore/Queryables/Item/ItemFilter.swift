//
//  ItemFilter.swift
//  
//
//  Created by Daniel Byon on 10/20/22.
//

import CoreData
import Foundation

public struct ItemFilter: SearchableFilter {

    public typealias ResultType = StoredItem

    public static var `default`: ItemFilter {
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

    public func makeFetchRequest(_ dataStore: DataStore) -> NSFetchRequest<StoredItem> {
        let request: NSFetchRequest<StoredItem> = StoredItem.fetchRequest()

        var predicates = [NSPredicate(format: "\(#keyPath(StoredItem.i_gameIndex)) == %d", game.index)]
        
        if !query.isEmpty {
            switch query {
            case .contains(let string):
                predicates.append(.init(format: "\(#keyPath(StoredItem.z_canonicalName)) CONTAINS %@", string.normalizedForSearch))
            case .exact(let string):
                predicates.append(.init(format: "\(#keyPath(StoredItem.z_canonicalName)) == %@", string.normalizedForSearch))
            }
        }

        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(StoredItem.i_nameIndex), ascending: true),
            NSSortDescriptor(key: #keyPath(StoredItem.z_generationIntroduced), ascending: true)
        ]
        request.relationshipKeyPathsForPrefetching = [
            #keyPath(StoredItem.bagInfo),
            #keyPath(StoredItem.berryInfo)
        ]
        return request
    }

}
