//
//  MoveInfo+CoreData.swift
//  Database
//
//  Created by Daniel Byon on 12/22/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import Foundation

// MARK: - Properties
public extension MoveInfo {

    var accuracy: Int? {
        get { (value(forKeyPath: #keyPath(MoveInfo.z_accuracy)) as? Int64)?.toInt() }
        set { z_accuracy = newValue?.toInt64() ?? 0 }
    }
    var category: MoveCategory {
        get { MoveCategory(rawValue: z_category!)! }
        set { z_category = newValue.rawValue }
    }
    var maxPP: Int? {
        get { (value(forKeyPath: #keyPath(MoveInfo.z_maxPP)) as? Int64)?.toInt() }
        set { z_maxPP = newValue?.toInt64() ?? 0 }
    }
    var moveDescription: String {
        get { z_moveDescription! }
        set { z_moveDescription = newValue }
    }
    var power: Int? {
        get { (value(forKeyPath: #keyPath(MoveInfo.z_power)) as? Int64)?.toInt() }
        set { z_power = newValue?.toInt64() ?? 0 }
    }
    var pp: Int? {
        get { (value(forKeyPath: #keyPath(MoveInfo.z_pp)) as? Int64)?.toInt() }
        set { z_pp = newValue?.toInt64() ?? 0 }
    }
    /// Unused
    var priority: Int {
        get { Int(z_priority) }
        set { z_priority = Int64(newValue) }
    }
    var targetAlly1: Bool {
        get { z_targetAlly1 }
        set { z_targetAlly1 = newValue }
    }
    var targetAlly2: Bool {
        get { z_targetAlly2 }
        set { z_targetAlly2 = newValue }
    }
    var targetDescription: String {
        get { z_targetDescription! }
        set { z_targetDescription = newValue }
    }
    var targetEnemy1: Bool {
        get { z_targetEnemy1 }
        set { z_targetEnemy1 = newValue }
    }
    var targetEnemy2: Bool {
        get { z_targetEnemy2 }
        set { z_targetEnemy2 = newValue }
    }
    var targetEnemy3: Bool {
        get { z_targetEnemy3 }
        set { z_targetEnemy3 = newValue }
    }
    var targetSelf: Bool {
        get { z_targetSelf }
        set { z_targetSelf = newValue }
    }

}
