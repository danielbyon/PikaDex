//
//  StoredCaughtPokemon+Extensions.swift
//  
//
//  Created by Daniel Byon on 11/3/22.
//

import Foundation

extension StoredCaughtPokemon {

    public var formName: String {
        get { z_formName! }
        set { z_formName = newValue }
    }

    public var game: Game {
        get { Game(rawValue: z_game!)! }
        set { z_game = newValue.rawValue; i_gameIndex = Int32(newValue.index) }
    }

    public var index: Int {
        get { Int(z_index) }
        set { z_index = Int64(newValue) }
    }

    public var pokemonName: String {
        get { z_pokemonName! }
        set { z_pokemonName = newValue }
    }

}
