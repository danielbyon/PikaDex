//
//  AppContext.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/10/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import Foundation
import Combine
import AppSupport

final class AppContext: ObservableObject {
    
    @UserDefault(key: "com.danielbyon.pokedex.currentGame", defaultValue: .sword) var currentGame: Game {
        willSet {
            objectWillChange.send()
        }
    }

}
