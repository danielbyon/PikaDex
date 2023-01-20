//
//  Environment+TeamStore.swift
//  
//
//  Created by Daniel Byon on 10/31/22.
//

import SwiftUI

private struct TeamStoreKey: EnvironmentKey {

    static var defaultValue: TeamStore { DefaultTeamStore() }

}

extension EnvironmentValues {

    public var teamStore: TeamStore {
        get { self[TeamStoreKey.self] }
        set { self[TeamStoreKey.self] = newValue }
    }

}

extension View {

    public func teamStore(_ teamStore: TeamStore) -> some View {
        environment(\.teamStore, teamStore)
    }

}

