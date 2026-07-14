//
//  IntentHandler.swift
//  TeamIntentHandler
//
//  Created by Daniel Byon on 12/7/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Dependencies
import Intents
import AppSupport
import PokedexCore

class IntentHandler: INExtension, TeamConfigurationIntentHandling {

    @Dependency(\.appSettings) var settings
    @Dependency(\.teamStorage) var storage

    func provideTeamOptionsCollection(for intent: TeamConfigurationIntent, with completion: @escaping (INObjectCollection<DynamicTeam>?, Error?) -> Void) {
        var sections: [INObjectSection<DynamicTeam>] = []
        for game in Game.selectableGames {
            guard let teams = getTeams(forGame: game) else { continue }
            let section = INObjectSection(title: "Pokémon \(game.title)", items: teams)
            sections.append(section)
        }

        let collection = INObjectCollection(sections: sections)
        completion(collection, nil)
    }

    private func getTeams(forGame game: Game) -> [DynamicTeam]? {
        guard let teams = storage.loadTeams(forGame: game) else { return nil }
        let dynamicTeams = teams.map(DynamicTeam.init)
        dynamicTeams.forEach { $0.game = game.rawValue }
        return dynamicTeams
    }

    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}

private extension DynamicTeam {

    convenience init(team: Team) {
        self.init(
            identifier: team.internalID.uuidString,
            display: team.name,
            subtitle: team.members.map({
                if $0.formName == $0.pokemon {
                    return $0.pokemon
                } else {
                    return "\($0.pokemon)-\($0.formName)"
                }
            }).joined(separator: ", "),
            image: nil)
    }

}
