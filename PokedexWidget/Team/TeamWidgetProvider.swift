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
            return TeamEntry(team: firstTeam)
        } else {
            return TeamEntry(team: nil)
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
        guard let allTeams = allTeams else {
            return TeamEntry(team: nil)
        }
        let entry: TeamEntry
        if let identifier = configuration.team?.identifier,
           let team = allTeams.first(where: { $0.internalID.uuidString == identifier }) {
            entry = TeamEntry(team: team)
        } else if let firstTeam = allTeams.first {
            entry = TeamEntry(team: firstTeam)
        } else {
            entry = TeamEntry(team: nil)
        }
        return entry
    }

}
