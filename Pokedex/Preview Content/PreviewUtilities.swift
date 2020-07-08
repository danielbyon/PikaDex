//
//  PreviewUtilities.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/22/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

extension Machine {

    static func generateTM1(for game: Game) -> Machine {
        let fetchRequest: NSFetchRequest<Machine> = Machine.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(#keyPath(Machine.z_number)) == 1 && \(#keyPath(Machine.z_game)) == %@", game.rawValue)
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Machine.z_number), ascending: true)]
        let machine = try! Dependencies.container.viewContext.fetch(fetchRequest).first!
        return machine
    }

}
