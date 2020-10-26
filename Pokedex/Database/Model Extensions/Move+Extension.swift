//
//  Move+CoreData.swift
//  Database
//
//  Created by Daniel Byon on 12/22/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Fetch Requests
public extension Move {

    static func allFetchRequest(for game: Game) -> NSFetchRequest<Move> {
        let predicate = NSPredicate(format: "\(#keyPath(Move.z_game)) == %@", game.rawValue)
        return makeFetchRequest(with: predicate, game: game)
    }

    static func fetchRequest(forType type: PokemonType, game: Game) -> NSFetchRequest<Move> {
        let predicate = NSPredicate(format: "\(#keyPath(Move.z_game)) == %@ AND z_type == %@", game.rawValue, type.rawValue)
        return makeFetchRequest(with: predicate, game: game)
    }

    static func fetchRequest(withName name: String, game: Game) -> NSFetchRequest<Move> {
        let predicate = NSPredicate(format: "\(#keyPath(Move.z_game)) == %@ AND \(#keyPath(Move.z_name)) == %@", game.rawValue, name)
        let request = makeFetchRequest(with: predicate, game: game)
        request.fetchLimit = 1
        return request
    }

    private static func makeFetchRequest(with predicate: NSPredicate, game: Game) -> NSFetchRequest<Move> {
        let request: NSFetchRequest<Move> = Move.fetchRequest()
        request.predicate = predicate
        request.relationshipKeyPathsForPrefetching = [
            #keyPath(Move.z_moveInfo)
        ]
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Move.z_name), ascending: true)]
        return request
    }

}

// MARK: - CanonicallyNamed
extension Move: CanonicallyNamed {

    var canonicalName: String { z_canonicalName ?? _missingString }

}

//// MARK: - Identifiable
//extension Move: Identifiable {
//
//    public var id: String { name }
//
//}

// MARK: - Properties
public extension Move {

    var game: Game {
        get { Game(rawValue: z_game!)! }
        set { z_game = newValue.rawValue; i_gameIndex = Int32(newValue.index) }
    }
    var generationIntroduced: Generation {
        get { Generation(rawValue: Int(z_generationIntroduced))! }
        set { z_generationIntroduced = Int64(newValue.rawValue) }
    }
    var index: Int {
        get { Int(z_index) }
        set { z_index = Int64(newValue) }
    }
    var name: String {
        get { z_name! }
        set { z_name = newValue; z_canonicalName = newValue.normalizedForSearch }
    }
    var type: PokemonType {
        get { PokemonType(rawValue: z_type!)! }
        set { z_type = newValue.rawValue }
    }

    var info: MoveInfo {
        get { z_moveInfo! }
        set { z_moveInfo = newValue }
    }

}
