//
//  ItemType.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/28/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

public enum ItemType: Int {
    case item
    case berry
}

extension ItemType: Codable { }

extension ItemType: Hashable { }
