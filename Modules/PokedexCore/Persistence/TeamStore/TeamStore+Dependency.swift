//
//  Environment+TeamStore.swift
//  
//
//  Created by Daniel Byon on 10/31/22.
//

import Dependencies
import SwiftUI

/// Carries a store through dependency values.
///
/// `TeamStore` operations are main-actor isolated, so callers access the store
/// through that actor-isolated interface.
private struct TeamStoreDependencyValue: @unchecked Sendable {
    let store: TeamStore
}

private struct TeamStoreKey: DependencyKey {
    static var liveValue: TeamStoreDependencyValue {
        fatalError("TeamStore must be supplied by the application composition root.")
    }

    static var testValue: TeamStoreDependencyValue {
        fatalError("Tests must inject an isolated TeamStore instance.")
    }
}

extension DependencyValues {
    public var teamStore: TeamStore {
        get { self[TeamStoreKey.self].store }
        set { self[TeamStoreKey.self] = TeamStoreDependencyValue(store: newValue) }
    }
}
