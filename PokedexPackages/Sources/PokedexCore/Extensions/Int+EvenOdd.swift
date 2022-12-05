//
//  Int+EvenOdd.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/2/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

extension Int {

    public var isEven: Bool { self % 2 == 0 }

    public var isOdd: Bool { !isEven }

}
