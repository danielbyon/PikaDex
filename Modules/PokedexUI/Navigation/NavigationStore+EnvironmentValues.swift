//
//  NavigationStore+EnvironmentValues.swift
//  
//
//  Created by Daniel Byon on 11/6/22.
//

import SwiftUI

private struct NavigationStoreKey: EnvironmentKey {

    static var defaultValue: NavigationStore { .init() }

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
