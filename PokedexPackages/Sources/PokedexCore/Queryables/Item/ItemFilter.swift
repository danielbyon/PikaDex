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
    public var query: String

    public init(
        game: Game,
        query: String = ""
    ) {
        self.game = game
        self.query = query
    }

    public func makeFetchRequest(_ dataStore: DataStore) -> NSFetchRequest<StoredItem> {
        let request: NSFetchRequest<StoredItem> = StoredItem.fetchRequest()

        var predicates = [NSPredicate(format: "\(#keyPath(StoredItem.i_gameIndex)) == %d", game.index)]
        if !query.isEmpty {
            predicates.append(NSPredicate(format: "\(#keyPath(StoredItem.z_canonicalName)) CONTAINS[cd] %@", query))
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
