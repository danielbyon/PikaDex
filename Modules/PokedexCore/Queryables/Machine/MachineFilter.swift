//
//  MachineFilter.swift
//  
//
//  Created by Daniel Byon on 10/21/22.
//

import CoreData
import Foundation

public struct MachineFilter: QueryFilter {

    public typealias ResultType = StoredMachine

    public static var `default`: MachineFilter {
        .init(game: .sword)
    }

    let game: Game

    public init(game: Game) {
        self.game = game
    }

    public func makeFetchRequest(_ dataStore: DataStore) -> NSFetchRequest<StoredMachine> {
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
