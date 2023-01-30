//
//  StoredStats+Extension.swift
//  Database
//
//  Created by Daniel Byon on 12/18/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Properties
public extension StoredStats {

    var total: Int { hp + attack + defense + specialAttack + specialDefense + speed }

}

// MARK: - Values
public extension StoredStats {

    var attack: Int {
        get { Int(z_attack) }
        set { z_attack = Int16(newValue) }
    }
    var defense: Int {
        get { Int(z_defense) }
        set { z_defense = Int16(newValue) }
    }
    var hp: Int {
        get { Int(z_hp) }
        set { z_hp = Int16(newValue) }
    }
    var specialAttack: Int {
        get { Int(z_specialAttack) }
        set { z_specialAttack = Int16(newValue) }
    }
    var specialDefense: Int {
        get { Int(z_specialDefense) }
        set { z_specialDefense = Int16(newValue) }
    }
    var speed: Int {
        get { Int(z_speed) }
        set { z_speed = Int16(newValue) }
    }

}
