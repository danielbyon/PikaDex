//
//  Environment+TeamStore.swift
//  
//
//  Created by Daniel Byon on 10/31/22.
//

import Dependencies
import SwiftUI

private struct TeamStoreKey: DependencyKey {
    static var liveValue: TeamStore {
        fatalError("TeamStore must be supplied by the application composition root.")
    }

    static var testValue: TeamStore {
        fatalError("Tests must inject an isolated TeamStore instance.")
    }
}

extension DependencyValues {
    public var teamStore: TeamStore {
        get { self[TeamStoreKey.self] }
        set { self[TeamStoreKey.self] = newValue }
    }
}
