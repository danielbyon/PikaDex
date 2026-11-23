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
    private let loadCurrentGame: @Sendable () -> Game

    init(loadCurrentGame: @escaping @Sendable () -> Game = Self.loadPersistedCurrentGame) {
        self.loadCurrentGame = loadCurrentGame
    }

    private var entryResolver: TeamEntryResolver {
        TeamEntryResolver(storage: storage, loadCurrentGame: loadCurrentGame)
    }

    func placeholder(in context: Context) -> TeamEntry {
        entryResolver.placeholderEntry()
    }

    func getSnapshot(for configuration: TeamConfigurationIntent, in context: Context, completion: @escaping (TeamEntry) -> ()) {
        let entry = entryResolver.configuredEntry(
            gameRawValue: configuration.team?.game,
            teamIdentifier: configuration.team?.identifier
        )
        completion(entry)
    }

    func getTimeline(for configuration: TeamConfigurationIntent, in context: Context, completion: @escaping (Timeline<TeamEntry>) -> ()) {
        let entry = entryResolver.configuredEntry(
            gameRawValue: configuration.team?.game,
            teamIdentifier: configuration.team?.identifier
        )
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

    private static func loadPersistedCurrentGame() -> Game {
        let key = "com.danielbyon.pokedex.currentGame"
        return TeamEntryResolver.decodePersistedGame(from: UserDefaults.appGroup.data(forKey: key))
    }

}
