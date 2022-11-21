//
//  StoredLearnsetEntry+Extensions.swift
//  Database
//
//  Created by Daniel Byon on 2/17/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

// MARK: - Values
public extension StoredLearnsetEntry {

    var game: Game {
        get { Game(rawValue: z_game!)! }
        set { z_game = newValue.rawValue }
    }

    var form: StoredPokemonForm {
        get { z_form! }
        set { z_form = newValue }
    }

    var level: Int {
        get { Int(z_level) }
        set { z_level = Int64(newValue) }
    }

    var move: StoredMove {
        get { z_move! }
        set { z_move = newValue }
    }

    var learnsetType: LearnsetType {
        get { LearnsetType(rawValue: z_learnsetType!)! }
        set { z_learnsetType = newValue.rawValue }
    }

    var fathers: [StoredPokemon] {
        get { z_fathers?.allObjects as? [StoredPokemon] ?? [] }
        set { z_fathers = NSSet(array: newValue) }
    }

    var machine: StoredMachine? {
        get { z_machine }
        set { z_machine = newValue }
    }

}
