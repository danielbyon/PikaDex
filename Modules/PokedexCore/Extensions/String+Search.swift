//
//  String+Search.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/6/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

public extension String {

    var normalizedForSearch: String { applyingTransform(StringTransform("Any-Latin; Latin-ASCII; Lower"), reverse: false) ?? self }

}
