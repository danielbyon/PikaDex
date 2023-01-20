//
//  Tab.swift
//  Pokedex
//
//  Created by Daniel Byon on 9/28/22.
//  Copyright © 2022 Daniel Byon. All rights reserved.
//

import Foundation

public enum Tab: String, Codable, Hashable {

    case abilities
    case battleAssistant
    case dualType
    case moves
    case items
    case locations
    case machines
    case natures
    case pokemon
    case teams
    case types

}

extension Tab: Identifiable {

    public var id: String { rawValue }

}
