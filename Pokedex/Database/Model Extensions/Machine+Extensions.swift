//
//  Machine+Extensions.swift
//  Database
//
//  Created by Daniel Byon on 2/17/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Fetch Requests
public extension Machine {

    static func allFetchRequest(for game: Game) -> NSFetchRequest<Machine> {
        let request: NSFetchRequest<Machine> = Machine.fetchRequest()
        request.predicate = NSPredicate(format: "\(#keyPath(Machine.i_gameIndex)) == %d", game.index)
        request.relationshipKeyPathsForPrefetching = [
            #keyPath(Machine.z_move),
            #keyPath(Machine.z_move.z_moveInfo)
        ]
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(Machine.i_gameIndex), ascending: true),
            NSSortDescriptor(key: #keyPath(Machine.z_number), ascending: true)
        ]
        return request
    }

}

//// MARK: - Identifiable
//extension Machine: Identifiable {
//
//    public var id: String { "\(number) \(move.name) \(game.rawValue)" }
//
//}

// MARK: - Values
public extension Machine {

    var game: Game {
        get { Game(rawValue: z_game!)! }
        set { z_game = newValue.rawValue; i_gameIndex = Int32(newValue.index) }
    }

    var number: Int {
        get { Int(z_number) }
        set { z_number = Int32(newValue) }
    }

    var move: Move {
        get { z_move! }
        set { z_move = newValue }
    }

    var type: MachineType {
        get { MachineType(intValue: Int(z_type))! }
        set { z_type = Int64(newValue.intValue) }
    }

}
