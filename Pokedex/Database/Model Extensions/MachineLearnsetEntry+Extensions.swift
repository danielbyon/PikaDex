//
//  MachineLearnsetEntry+Extensions.swift
//  Database
//
//  Created by Daniel Byon on 2/17/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Fetch Requests
public extension MachineLearnsetEntry {

    static func fetchRequest(forPokemonForm pokemonForm: PokemonForm) -> NSFetchRequest<MachineLearnsetEntry> {
        let request: NSFetchRequest<MachineLearnsetEntry> = MachineLearnsetEntry.fetchRequest()
        request.predicate = NSPredicate(format: "\(#keyPath(MachineLearnsetEntry.z_form)) == %@", pokemonForm)
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(MachineLearnsetEntry.z_machine.z_type), ascending: true),
            NSSortDescriptor(key: #keyPath(MachineLearnsetEntry.z_machine.z_number), ascending: true)
        ]
        commonConfigureRequest(request)
        return request
    }

    static func fetchRequest(for move: Move, game: Game) -> NSFetchRequest<MachineLearnsetEntry> {
        let request: NSFetchRequest<MachineLearnsetEntry> = MachineLearnsetEntry.fetchRequest()
        request.predicate = NSPredicate(format: "\(#keyPath(MachineLearnsetEntry.z_machine.z_move)) == %@ AND \(#keyPath(MachineLearnsetEntry.z_form.z_game)) == %@", move, game.rawValue)
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(MachineLearnsetEntry.z_form.z_index), ascending: true),
            NSSortDescriptor(key: #keyPath(MachineLearnsetEntry.z_form.z_formIndex), ascending: true),
            NSSortDescriptor(key: #keyPath(MachineLearnsetEntry.z_machine.z_number), ascending: true)
        ]
        commonConfigureRequest(request)
        return request
    }

    private static func commonConfigureRequest(_ request: NSFetchRequest<MachineLearnsetEntry>) {
        request.relationshipKeyPathsForPrefetching = [
            #keyPath(MachineLearnsetEntry.z_form.z_pokemon),
            #keyPath(MachineLearnsetEntry.z_machine),
            #keyPath(MachineLearnsetEntry.z_machine.z_move),
            #keyPath(MachineLearnsetEntry.z_machine.z_move.z_moveInfo)
        ]
        request.returnsObjectsAsFaults = false

    }

}

// MARK: - Identifiable
extension MachineLearnsetEntry: Identifiable {

    public var id: String { "\(machine.number) \(machine.type.rawValue)" }

}

// MARK: - Values
public extension MachineLearnsetEntry {

    var form: PokemonForm {
        get { z_form! }
        set { z_form = newValue }
    }

    var machine: Machine {
        get { z_machine! }
        set { z_machine = newValue }
    }

}
