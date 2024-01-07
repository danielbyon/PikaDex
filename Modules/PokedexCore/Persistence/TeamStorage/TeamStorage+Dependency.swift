//
//  EnvironmentKey+TeamStorage.swift
//  
//
//  Created by Daniel Byon on 10/26/22.
//

import Dependencies
import SwiftUI

private enum TeamStorageKey: DependencyKey {
    static var liveValue: TeamStorage = UserDefaults.appGroup
    static var testValue: TeamStorage = UserDefaults.appGroup
}

extension DependencyValues {
    public var teamStorage: TeamStorage {
        get { self[TeamStorageKey.self] }
        set { self[TeamStorageKey.self] = newValue }
    }
}
