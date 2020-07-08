//
//  ErrorInfo.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/28/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

struct ErrorInfo: Identifiable {
    let error: Error?
    var id: String = UUID().uuidString
}
