//
//  IntentHandler.swift
//  TeamIntentHandler
//
//  Created by Daniel Byon on 12/7/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Intents
import AppSupport

class IntentHandler: INExtension, TeamConfigurationIntentHandling {

    private let settings = AppSettings()
    private let storage = TeamStorage()

    func provideTeamOptionsCollection(for intent: TeamConfigurationIntent, with completion: @escaping (INObjectCollection<DynamicTeam>?, Error?) -> Void) {
        guard let teams = storage.loadTeams(forGame: settings.currentGame) else {
            completion(nil, nil)
            return
        }

        let dynamicTeams = teams.map {
            DynamicTeam(
                identifier: $0.internalID.uuidString,
                display: $0.name,
                subtitle: $0.members.map({
                    if $0.formName == $0.pokemon {
                        return $0.pokemon
                    } else {
                        return "\($0.pokemon)-\($0.formName)"
                    }
                }).joined(separator: ", "),
                image: nil)
        }
        let section = INObjectSection(title: settings.currentGame.title, items: dynamicTeams)
        let collection = INObjectCollection(sections: [section])
        completion(collection, nil)
    }

    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}
