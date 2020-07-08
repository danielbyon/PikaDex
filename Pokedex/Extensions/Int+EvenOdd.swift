//
//  Int+EvenOdd.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/2/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

public extension Int {

    var isEven: Bool { self % 2 == 0 }

    var isOdd: Bool { !isEven }

}
