//
//  TeamEntry.swift
//  PokedexWidgetExtension
//
//  Created by Daniel Byon on 12/8/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import WidgetKit

struct TeamEntry: TimelineEntry {

    let date: Date
    let teamName: String?
    let teamMemberNames: [String]
    let teamMemberSpriteNames: [String]
    let teamID: String

    struct ViewModel {

        let teamName: String
        let members: [TeamMember]

        struct TeamMember {
            let name: String
            let spriteName: String
        }

    }

    init(date: Date = Date(), team: Team?) {
        self.date = date
        self.teamName = team?.name
        self.teamMemberNames = team?.members.map { $0.pokemon } ?? []
        self.teamMemberSpriteNames = team?.members.map {
            PokemonImageNameFormatter.menuSpriteName(forPokemonName: $0.pokemon, formName: $0.formName)
        } ?? []
        self.teamID = team?.internalID.uuidString ?? ""
    }

}
