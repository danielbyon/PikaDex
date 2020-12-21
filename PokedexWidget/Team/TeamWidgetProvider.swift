//
//  TeamWidgetProvider.swift
//  PokedexWidgetExtension
//
//  Created by Daniel Byon on 12/8/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import WidgetKit
import Intents

struct TeamProvider: IntentTimelineProvider {

    private let settings = AppSettings()
    private let storage = TeamStorage()

    private var allTeams: [Team]? { storage.loadTeams(forGame: settings.currentGame) }

    func placeholder(in context: Context) -> TeamEntry {
        if let allTeams = allTeams,
              let firstTeam = allTeams.first {
            return TeamEntry(team: firstTeam, game: nil)
        } else {
            return TeamEntry(team: nil, game: nil)
        }
    }

    func getSnapshot(for configuration: TeamConfigurationIntent, in context: Context, completion: @escaping (TeamEntry) -> ()) {
        let entry = getTeamEntry(for: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: TeamConfigurationIntent, in context: Context, completion: @escaping (Timeline<TeamEntry>) -> ()) {
        let entry = getTeamEntry(for: configuration)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

    private func getTeamEntry(for configuration: TeamConfigurationIntent) -> TeamEntry {
        let entry: TeamEntry

        if let dynamicTeam = configuration.team,
           let gameRawValue = dynamicTeam.game,
           let game = Game(rawValue: gameRawValue),
           let allTeams = storage.loadTeams(forGame: game),
           let identifier = configuration.team?.identifier,
           let team = allTeams.first(where: { $0.internalID.uuidString == identifier }) {
            entry = TeamEntry(team: team, game: dynamicTeam.game)
        } else {
            let allTeams = storage.loadTeams(forGame: settings.currentGame)
            if let firstTeam = allTeams?.first {
                entry = TeamEntry(team: firstTeam, game: nil)
            } else {
                entry = TeamEntry(team: nil, game: nil)
            }
        }

        return entry
    }

}
