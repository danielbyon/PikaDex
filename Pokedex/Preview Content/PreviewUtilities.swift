//
//  PreviewUtilities.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/22/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import PokedexCore

extension Machine {

    /// Returns the first machine from an isolated preview bootstrap.
    static func generateTM1(for game: Game) throws -> Machine? {
        let stores = try PersistenceBootstrap.preview()
        return try stores.pokedex.fetch(Machine.self, filter: MachineFilter(game: game)).first
    }

}
