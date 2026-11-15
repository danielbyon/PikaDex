//
//  TeamStorage.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/7/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

/// Synchronous storage for the saved teams associated with each game.
///
/// Implementations must be safe to pass between concurrency domains.
public protocol TeamStorage: Sendable {

    func loadTeams(forGame game: Game) -> [Team]?

    func saveTeams(_ teams: [Team], forGame game: Game)

}

/// Stores teams in the shared app-group defaults suite using the existing JSON format.
///
/// The process-wide lock serializes defaults access made through this adapter. Direct
/// access to the suite and access from other processes do not use this lock.
final class AppGroupTeamStorage: TeamStorage, @unchecked Sendable {

    // The defaults instance stays private, and every read or write uses this lock.
    private static let defaultsLock = NSLock()
    private let defaults: UserDefaults

    init(suiteName: String = UserDefaults.appGroupSuiteName) {
        defaults = UserDefaults(suiteName: suiteName)!
    }

    private static func teamsKey(forGame game: Game) -> String { "teams-\(game.rawValue)" }

    func loadTeams(forGame game: Game) -> [Team]? {
        let key = Self.teamsKey(forGame: game)
        guard let data = Self.defaultsLock.withLock({ defaults.data(forKey: key) }) else { return nil }

        do {
            return try JSONDecoder().decode([Team].self, from: data)
        } catch {
            debugPrint(error)
            return nil
        }
    }

    func saveTeams(_ teams: [Team], forGame game: Game) {
        do {
            let data = try JSONEncoder().encode(teams)
            let key = Self.teamsKey(forGame: game)
            Self.defaultsLock.withLock { defaults.set(data, forKey: key) }
        } catch {
            debugPrint(error)
        }
    }

}
