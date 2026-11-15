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

    /// Returns the process-wide defaults handle for the shared app-group suite.
    public static var appGroup: UserDefaults {
        SharedAppGroupDefaults.shared.value
    }

}

/// Keeps one defaults handle for preferences observed by SwiftUI.
///
/// Foundation documents `UserDefaults` as thread-safe. The stored reference is
/// immutable, so this narrow wrapper can be shared without declaring
/// `UserDefaults` itself `Sendable`.
private final class SharedAppGroupDefaults: @unchecked Sendable {

    static let shared = SharedAppGroupDefaults()

    let value: UserDefaults

    private init() {
        value = UserDefaults(suiteName: UserDefaults.appGroupSuiteName)!
    }
}
