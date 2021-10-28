//
//  BreedLearnsetEntry+Extensions.swift
//  Database
//
//  Created by Daniel Byon on 2/17/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Fetch Requests
public extension BreedLearnsetEntry {

    static func fetchRequest(forPokemonForm pokemonForm: PokemonForm) -> NSFetchRequest<BreedLearnsetEntry> {
        let request: NSFetchRequest<BreedLearnsetEntry> = BreedLearnsetEntry.fetchRequest()
        request.predicate = NSPredicate(format: "\(#keyPath(BreedLearnsetEntry.z_form)) == %@", pokemonForm)
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(BreedLearnsetEntry.z_move.z_name), ascending: true)
        ]
        commonConfigureRequest(request)
        return request
    }

    static func fetchRequest(for move: Move, game: Game) -> NSFetchRequest<BreedLearnsetEntry> {
        let request: NSFetchRequest<BreedLearnsetEntry> = BreedLearnsetEntry.fetchRequest()
        request.predicate = NSPredicate(format: "\(#keyPath(BreedLearnsetEntry.z_move)) == %@ AND \(#keyPath(BreedLearnsetEntry.z_form.z_game)) == %@", move, game.rawValue)
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(BreedLearnsetEntry.z_form.z_index), ascending: true),
            NSSortDescriptor(key: #keyPath(BreedLearnsetEntry.z_form.z_formIndex), ascending: true)
        ]
        commonConfigureRequest(request)
        return request
    }

    private static func commonConfigureRequest(_ request: NSFetchRequest<BreedLearnsetEntry>) {
        request.relationshipKeyPathsForPrefetching = [
            #keyPath(BreedLearnsetEntry.z_move),
            #keyPath(BreedLearnsetEntry.z_move.z_moveInfo),
            #keyPath(BreedLearnsetEntry.z_form.z_pokemon)
        ]
        request.returnsObjectsAsFaults = false
    }

}

//// MARK: - Identifiable
//extension BreedLearnsetEntry: Identifiable {
//
//    public var id: String {
//        "\(move.name) \(fathers.compactMap { $0.name }.joined(separator: ","))"
//    }
//
//}

// MARK: - Values
public extension BreedLearnsetEntry {

    var fathers: [StoredPokemon] {
        get { z_fathers!.allObjects as! [StoredPokemon] }
        set { z_fathers = NSSet(array: newValue) }
    }

    var form: PokemonForm {
        get { z_form! }
        set { z_form = newValue }
    }

    var move: Move {
        get { z_move! }
        set { z_move = newValue }
    }

}
