//
//  NavigationStore+EnvironmentValues.swift
//  
//
//  Created by Daniel Byon on 11/6/22.
//

import SwiftUI

private struct NavigationStoreKey: EnvironmentKey {

    static var defaultValue: NavigationStore {
        // SwiftUI evaluates environment defaults while building the main-actor
        // view hierarchy. The protocol requirement itself is nonisolated, so
        // make that framework contract explicit at this boundary.
        MainActor.assumeIsolated { NavigationStore() }
    }

}

extension EnvironmentValues {

    public var navigationStore: NavigationStore {
        get { self[NavigationStoreKey.self] }
        set { self[NavigationStoreKey.self] = newValue }
    }

}

extension View {

    public func navigationStore(_ store: NavigationStore) -> some View {
        environment(\.navigationStore, store)
    }

}
