//
//  EnvironmentKey+TeamStorage.swift
//  
//
//  Created by Daniel Byon on 10/26/22.
//

import Dependencies
import Foundation
import SwiftUI

/// Instance-isolated volatile team persistence for previews and tests.
///
/// Callers must construct a new instance for every dependency context. The
/// internal lock permits widget-style reads and background persistence writes
/// without introducing shared process-wide test state.
public final class VolatileTeamStorage: TeamStorage {

    private let lock = NSLock()
    private var teamsByGame: [Game: [Team]] = [:]

    public init() { }

    public func loadTeams(forGame game: Game) -> [Team]? {
        lock.lock()
        defer { lock.unlock() }
        return teamsByGame[game]
    }

    public func saveTeams(_ teams: [Team], forGame game: Game) {
        lock.lock()
        teamsByGame[game] = teams
        lock.unlock()
    }
}

private enum TeamStorageKey: DependencyKey {
    static let liveValue: TeamStorage = UserDefaults.appGroup
    static var testValue: TeamStorage {
        fatalError("Tests must inject a fresh TeamStorage instance.")
    }
}

extension DependencyValues {
    public var teamStorage: TeamStorage {
        get { self[TeamStorageKey.self] }
        set { self[TeamStorageKey.self] = newValue }
    }
}
