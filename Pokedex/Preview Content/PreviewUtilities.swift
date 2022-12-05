//
//  PreviewUtilities.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/22/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData
import PokedexCore

extension StoredMachine {

    static func generateTM1(for game: Game) -> StoredMachine {
        let fetchRequest: NSFetchRequest<StoredMachine> = StoredMachine.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(#keyPath(StoredMachine.z_number)) == 1 && \(#keyPath(StoredMachine.z_game)) == %@", game.rawValue)
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(StoredMachine.z_number), ascending: true)]
        let machine = try! NSPersistentContainer.pokedexContainer.viewContext.fetch(fetchRequest).first!
        return machine
    }

}
