//
//  TeamStorage.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/7/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

public protocol TeamStorage {

    func loadTeams(forGame game: Game) -> [Team]?

    func saveTeams(_ teams: [Team], forGame game: Game)

}

extension UserDefaults: TeamStorage {

    private func teamsKey(forGame game: Game) -> String { "teams-\(game.rawValue)" }

    public func loadTeams(forGame game: Game) -> [Team]? {
        do {
            guard let data = data(forKey: teamsKey(forGame: game)) else { return nil }
            let teams = try JSONDecoder().decode([Team].self, from: data)
            return teams
        } catch {
            debugPrint(error)
            return nil
        }
    }

    public func saveTeams(_ teams: [Team], forGame game: Game) {
        do {
            let data = try JSONEncoder().encode(teams)
            set(data, forKey: teamsKey(forGame: game))
        } catch {
            debugPrint(error)
        }
    }

}
