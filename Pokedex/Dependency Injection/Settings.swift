//
//  AppSettings.swift
//  Pokedex
//
//  Created by Daniel Byon on 1/26/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import Combine
import AppSupport

final class AppSettings: ObservableObject {

    @UserDefault(key: "com.danielbyon.pokedex.shouldUseMetersForHeight", defaultValue: true) var shouldUseMetersForHeight: Bool {
        didSet {
            objectWillChange.send()
        }
    }

    @UserDefault(key: "com.danielbyon.pokedex.shouldUseKilogramsForWeight", defaultValue: true) var shouldUseKilogramsForWeight: Bool {
        didSet {
            objectWillChange.send()
        }
    }

}
