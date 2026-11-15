//
//  UserDefaults+AppGroup.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/29/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

extension UserDefaults {

    static let appGroupSuiteName = "group.com.danielbyon.pokepedia"

    /// Creates a defaults object for the shared app-group suite.
    public static var appGroup: UserDefaults {
        UserDefaults(suiteName: appGroupSuiteName)!
    }

}
