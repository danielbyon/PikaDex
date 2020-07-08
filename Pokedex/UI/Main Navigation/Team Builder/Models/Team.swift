//
//  Team.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/22/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

struct Team: Codable {

    var name: String
    var members: [TeamMember]
    let internalID: UUID

}

extension Team: Comparable {

    static func < (lhs: Team, rhs: Team) -> Bool {
        if lhs.name == rhs.name {
            return lhs.internalID.uuidString < rhs.internalID.uuidString
        } else {
            return lhs.name < rhs.name
        }
    }

}

extension Team: Identifiable {

    var id: String { internalID.uuidString }

}
