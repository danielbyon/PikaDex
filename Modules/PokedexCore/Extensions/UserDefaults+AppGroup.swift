//
//  UserDefaults+AppGroup.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/29/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

extension UserDefaults {

    public static let appGroup = UserDefaults(suiteName: "group.com.danielbyon.pokepedia")!

}
