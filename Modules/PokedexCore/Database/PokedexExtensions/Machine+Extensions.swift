//
//  StoredMachine+Extensions.swift
//  Database
//
//  Created by Daniel Byon on 2/17/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Fetch Requests
public extension StoredMachine {

    static func allFetchRequest(for game: Game) -> NSFetchRequest<StoredMachine> {
        let request: NSFetchRequest<StoredMachine> = StoredMachine.fetchRequest()
        request.predicate = NSPredicate(format: "\(#keyPath(StoredMachine.i_gameIndex)) == %d", game.databaseIndex)
        request.relationshipKeyPathsForPrefetching = [
            #keyPath(StoredMachine.z_move)
        ]
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(StoredMachine.i_gameIndex), ascending: true),
            NSSortDescriptor(key: #keyPath(StoredMachine.z_number), ascending: true)
        ]
        return request
    }

}

//// MARK: - Identifiable
//extension StoredMachine: Identifiable {
//
//    public var id: String { "\(number) \(move.name) \(game.rawValue)" }
//
//}

// MARK: - Values
public extension StoredMachine {

    var game: Game {
        get { Game(rawValue: z_game!)! }
        set { z_game = newValue.rawValue; i_gameIndex = Int16(newValue.databaseIndex) }
    }

    var number: Int {
        get { Int(z_number) }
        set { z_number = Int16(newValue) }
    }

    var move: StoredMove {
        get { z_move! }
        set { z_move = newValue }
    }

    var type: MachineType {
        get { MachineType(intValue: Int(z_type))! }
        set { z_type = Int16(newValue.intValue) }
    }

}
