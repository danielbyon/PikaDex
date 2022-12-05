//
//  EnvironmentKey+TeamStorage.swift
//  
//
//  Created by Daniel Byon on 10/26/22.
//

import SwiftUI

private struct TeamStorageKey: EnvironmentKey {

    static var defaultValue: TeamStorage { UserDefaults.appGroup }

}

extension EnvironmentValues {

    public var teamStorage: TeamStorage {
        get { self[TeamStorageKey.self] }
        set { self[TeamStorageKey.self] = newValue }
    }

}

extension View {

    public func teamStorage(_ teamStorage: TeamStorage) -> some View {
        environment(\.teamStorage, teamStorage)
    }

}
