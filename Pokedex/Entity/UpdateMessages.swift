//
//  UpdateMessages.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/21/21.
//  Copyright © 2021 Daniel Byon. All rights reserved.
//

import Foundation

struct UpdateMessages: Codable {

    let bugFixes: [String]
    let newFeatures: [String]
    let upcoming: [String]

}
