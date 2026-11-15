//
//  EnvironmentKey+TeamStorage.swift
//  
//
//  Created by Daniel Byon on 10/26/22.
//

import Dependencies
import Foundation
import SwiftUI

/// Stores preview and test teams in memory.
///
/// The lock protects the game-to-team map during every read and write.
public final class VolatileTeamStorage: TeamStorage, @unchecked Sendable {

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
    static let liveValue: TeamStorage = AppGroupTeamStorage()

    /// Gives test dependency contexts in-memory storage without touching the app-group suite.
    /// Tests that need a particular instance should override this dependency explicitly.
    static var testValue: TeamStorage { VolatileTeamStorage() }
}

extension DependencyValues {
    public var teamStorage: TeamStorage {
        get { self[TeamStorageKey.self] }
        set { self[TeamStorageKey.self] = newValue }
    }
}
