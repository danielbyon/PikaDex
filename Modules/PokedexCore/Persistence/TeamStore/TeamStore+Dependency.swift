//
//  Environment+TeamStore.swift
//  
//
//  Created by Daniel Byon on 10/31/22.
//

import Dependencies
import SwiftUI

private struct TeamStoreKey: DependencyKey {
    static var liveValue: TeamStore = DefaultTeamStore.shared
    static var testValue: TeamStore = DefaultTeamStore.shared
}

extension DependencyValues {
    public var teamStore: TeamStore {
        get { self[TeamStoreKey.self] }
        set { self[TeamStoreKey.self] = newValue }
    }
}
