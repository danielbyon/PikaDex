//
//  PokemonType+Strings.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/4/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

extension PokemonType {

    public var abbreviation: String { String(rawValue.prefix(3)) }

}
