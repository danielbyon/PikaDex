//
//  LevelLearnsetEntry+Extensions.swift
//  Database
//
//  Created by Daniel Byon on 2/15/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Fetch Requests
public extension LevelLearnsetEntry {

    static func fetchRequest(forPokemonForm pokemonForm: PokemonForm) -> NSFetchRequest<LevelLearnsetEntry> {
        let request: NSFetchRequest<LevelLearnsetEntry> = LevelLearnsetEntry.fetchRequest()
        request.predicate = NSPredicate(format: "\(#keyPath(LevelLearnsetEntry.z_form)) == %@", pokemonForm)
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(LevelLearnsetEntry.z_level), ascending: true),
            NSSortDescriptor(key: #keyPath(LevelLearnsetEntry.z_move.z_name), ascending: true)
        ]
        commonConfigureRequest(request)
        return request
    }

    static func fetchRequest(forPokemonForm pokemonForm: PokemonForm, maxLevel: Int) -> NSFetchRequest<LevelLearnsetEntry> {
        let request: NSFetchRequest<LevelLearnsetEntry> = LevelLearnsetEntry.fetchRequest()
        request.predicate = NSPredicate(format: "\(#keyPath(LevelLearnsetEntry.z_form)) == %@ && \(#keyPath(LevelLearnsetEntry.z_level)) <= %d", pokemonForm, maxLevel)
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(LevelLearnsetEntry.z_level), ascending: true),
            NSSortDescriptor(key: #keyPath(LevelLearnsetEntry.z_move.z_name), ascending: true)
        ]
        commonConfigureRequest(request)
        return request
    }

    static func fetchRequest(for move: Move, game: Game) -> NSFetchRequest<LevelLearnsetEntry> {
        let request: NSFetchRequest<LevelLearnsetEntry> = LevelLearnsetEntry.fetchRequest()
        request.predicate = NSPredicate(format: "\(#keyPath(LevelLearnsetEntry.z_move)) == %@ AND \(#keyPath(LevelLearnsetEntry.z_form.z_game)) == %@", move, game.rawValue)
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(LevelLearnsetEntry.z_form.z_index), ascending: true),
            NSSortDescriptor(key: #keyPath(LevelLearnsetEntry.z_form.z_formIndex), ascending: true),
            NSSortDescriptor(key: #keyPath(LevelLearnsetEntry.z_level), ascending: true)
        ]
        commonConfigureRequest(request)
        return request
    }

    private static func commonConfigureRequest(_ request: NSFetchRequest<LevelLearnsetEntry>) {
        request.relationshipKeyPathsForPrefetching = [
            #keyPath(LevelLearnsetEntry.z_move),
            #keyPath(LevelLearnsetEntry.z_move.z_moveInfo),
            #keyPath(LevelLearnsetEntry.z_form.z_pokemon)
        ]
        request.returnsObjectsAsFaults = false

    }

}

// MARK: - Identifiable
extension LevelLearnsetEntry: Identifiable {

    public var id: String { "\(move.name) \(level)" }

}

// MARK: - Values
public extension LevelLearnsetEntry {

    var form: PokemonForm {
        get { z_form! }
        set { z_form = newValue }
    }
    
    var level: Int {
        get { Int(z_level) }
        set { z_level = Int64(newValue) }
    }
    
    var move: Move {
        get { z_move! }
        set { z_move = newValue }
    }
    
}
