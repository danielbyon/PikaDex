//
//  AppSettings.swift
//  Pokedex
//
//  Created by Daniel Byon on 1/26/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Dependencies
import SwiftUI
import Combine
import AppSupport
import PokedexCore

public final class AppSettings: ObservableObject {

    @AppGroupStorage(key: "com.danielbyon.pokedex.currentGame") public var currentGame: Game = .sword {
        willSet {
            objectWillChange.send()
        }
    }

    @AppGroupStorage(key: "shouldUseMetersForHeight") public var shouldUseMetersForHeight = true {
        willSet {
            objectWillChange.send()
        }
    }

    @AppGroupStorage(key: "shouldUseKilogramsForWeight") public var shouldUseKilogramsForWeight = true {
        willSet {
            objectWillChange.send()
        }
    }

}

private enum AppSettingsKey: DependencyKey {
    static var liveValue: AppSettings = AppSettings()
    static var testValue: AppSettings = AppSettings()
}

extension DependencyValues {
    var appSettings: AppSettings {
        get { self[AppSettingsKey.self] }
        set { self[AppSettingsKey.self] = newValue }
    }
}
