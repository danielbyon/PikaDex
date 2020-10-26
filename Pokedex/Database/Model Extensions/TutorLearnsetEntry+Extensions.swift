//
//  TutorLearnsetEntry+Extensions.swift
//  Database
//
//  Created by Daniel Byon on 2/17/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Fetch Requests
public extension TutorLearnsetEntry {

    static func fetchRequest(forPokemonForm pokemonForm: PokemonForm) -> NSFetchRequest<TutorLearnsetEntry> {
        let request: NSFetchRequest<TutorLearnsetEntry> = TutorLearnsetEntry.fetchRequest()
        request.predicate = NSPredicate(format: "\(#keyPath(TutorLearnsetEntry.z_form)) == %@", pokemonForm)
        request.relationshipKeyPathsForPrefetching = [
            #keyPath(TutorLearnsetEntry.z_move),
            #keyPath(TutorLearnsetEntry.z_move.z_moveInfo)
        ]
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TutorLearnsetEntry.z_move.z_name), ascending: true)
        ]
        return request
    }

    static func fetchRequest(for move: Move, game: Game) -> NSFetchRequest<TutorLearnsetEntry> {
        let request: NSFetchRequest<TutorLearnsetEntry> = TutorLearnsetEntry.fetchRequest()
        request.predicate = NSPredicate(format: "\(#keyPath(TutorLearnsetEntry.z_move)) == %@ AND \(#keyPath(TutorLearnsetEntry.z_form.z_game)) == %@", move, game.rawValue)
        request.relationshipKeyPathsForPrefetching = [
            #keyPath(TutorLearnsetEntry.z_form),
            #keyPath(TutorLearnsetEntry.z_form.z_pokemon),
            #keyPath(TutorLearnsetEntry.z_move),
            #keyPath(TutorLearnsetEntry.z_move.z_moveInfo)
        ]
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TutorLearnsetEntry.z_form.z_index), ascending: true),
            NSSortDescriptor(key: #keyPath(TutorLearnsetEntry.z_form.z_formIndex), ascending: true)
        ]
        return request
    }

}

//// MARK: - Identifiable
//extension TutorLearnsetEntry: Identifiable {
//
//    public var id: String { move.name }
//
//}

// MARK: - Values
public extension TutorLearnsetEntry {

    var form: PokemonForm {
        get { z_form! }
        set { z_form = newValue }
    }

    var move: Move {
        get { z_move! }
        set { z_move = newValue }
    }

}
