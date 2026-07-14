//
//  TeamWidgetProvider.swift
//  PokedexWidgetExtension
//
//  Created by Daniel Byon on 12/8/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Dependencies
import AppSupport
import Foundation
import WidgetKit
import Intents
import PokedexCore

struct TeamProvider: IntentTimelineProvider {

    @Dependency(\.teamStorage) var storage

    /// Resolves the persisted game once for each WidgetKit callback.
    ///
    /// WidgetKit may invoke callbacks on arbitrary threads and may retain a
    /// provider for multiple callbacks. Injected loaders must therefore be
    /// synchronous and thread-safe. The resulting `Game` is an immutable
    /// snapshot used for the complete callback.
    private let loadCurrentGame: () -> Game

    init(loadCurrentGame: @escaping () -> Game = Self.loadPersistedCurrentGame) {
        self.loadCurrentGame = loadCurrentGame
    }

    func placeholder(in context: Context) -> TeamEntry {
        let game = loadCurrentGame()
        if let allTeams = storage.loadTeams(forGame: game),
              let firstTeam = allTeams.first {
            return TeamEntry(team: firstTeam, game: nil)
        } else {
            return TeamEntry(team: nil, game: nil)
        }
    }

    func getSnapshot(for configuration: TeamConfigurationIntent, in context: Context, completion: @escaping (TeamEntry) -> ()) {
        let entry = getTeamEntry(for: configuration, fallbackGame: loadCurrentGame())
        completion(entry)
    }

    func getTimeline(for configuration: TeamConfigurationIntent, in context: Context, completion: @escaping (Timeline<TeamEntry>) -> ()) {
        let entry = getTeamEntry(for: configuration, fallbackGame: loadCurrentGame())
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

    private func getTeamEntry(for configuration: TeamConfigurationIntent, fallbackGame: Game) -> TeamEntry {
        let entry: TeamEntry

        if let dynamicTeam = configuration.team,
           let gameRawValue = dynamicTeam.game,
           let game = Game(rawValue: gameRawValue),
           let allTeams = storage.loadTeams(forGame: game),
           let identifier = configuration.team?.identifier,
           let team = allTeams.first(where: { $0.internalID.uuidString == identifier }) {
            entry = TeamEntry(team: team, game: dynamicTeam.game)
        } else {
            let allTeams = storage.loadTeams(forGame: fallbackGame)
            if let firstTeam = allTeams?.first {
                entry = TeamEntry(team: firstTeam, game: nil)
            } else {
                entry = TeamEntry(team: nil, game: nil)
            }
        }

        return entry
    }

    private static func loadPersistedCurrentGame() -> Game {
        let key = "com.danielbyon.pokedex.currentGame"
        guard let data = UserDefaults.appGroup.data(forKey: key),
              let game = try? JSONDecoder().decode(Game.self, from: data) else {
            return .sword
        }
        return game
    }

}
