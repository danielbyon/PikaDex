//
//  MoveFilter.swift
//  
//
//  Created by Daniel Byon on 9/29/22.
//

import CoreData
import Foundation

public struct MoveFilter: SearchableFilter {

    public typealias ResultType = StoredMove

    public static var `default`: MoveFilter {
        .init(game: .national)
    }

    public let game: Game
    public let type: PokemonType?
    public var query: SearchQuery

    public init(
        game: Game,
        type: PokemonType? = nil,
        query: SearchQuery = .empty
    ) {
        self.game = game
        self.type = type
        self.query = query
    }

    public func makeFetchRequest(_ dataStore: DataStore) -> NSFetchRequest<StoredMove> {
        let fetchRequest: NSFetchRequest<StoredMove> = StoredMove.fetchRequest()

        var predicates = [
            NSPredicate(format: "\(#keyPath(StoredMove.z_game)) == %@", game.rawValue)
        ]
        if let type {
            predicates.append(.init(format: "\(#keyPath(StoredMove.z_type)) == %@", type.rawValue))
        }
        if !query.isEmpty {
            switch query {
            case .contains(let string):
                predicates.append(.init(format: "\(#keyPath(StoredMove.z_canonicalName)) CONTAINS %@", string.normalizedForSearch))
            case .exact(let string):
                predicates.append(.init(format: "\(#keyPath(StoredMove.z_canonicalName)) == %@", string.normalizedForSearch))
            }
        }
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(StoredMove.z_name), ascending: true)]
        return fetchRequest
    }

}
