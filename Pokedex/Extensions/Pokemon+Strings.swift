//
//  StoredPokemon+Strings.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/20/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import Foundation

extension StoredPokemon {

    func pokedexNumberString(forKeyPath keyPath: String) -> String {
        let number = value(forKeyPath: keyPath) as! NSNumber
        return NumberFormatter.threeDigit.string(from: number)!
    }

}
