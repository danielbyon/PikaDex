//
//  TeamStorage.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/7/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

struct TeamStorage {

    private(set) var storage: UserDefaults = .appGroup

    private func teamsKey(forGame game: Game) -> String { "teams-\(game.rawValue)" }

    func loadTeams(forGame game: Game) -> [Team]? {
        do {
            guard let data = storage.data(forKey: teamsKey(forGame: game)) else { return nil }
            let teams = try JSONDecoder().decode([Team].self, from: data)
            return teams
        } catch {
            debugPrint(error)
            return nil
        }
    }

    func saveTeams(_ teams: [Team], forGame game: Game) {
        do {
            let data = try JSONEncoder().encode(teams)
            storage.set(data, forKey: teamsKey(forGame: game))
        } catch {
            debugPrint(error)
        }
    }

}
