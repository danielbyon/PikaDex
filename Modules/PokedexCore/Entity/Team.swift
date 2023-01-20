//
//  Team.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/22/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

public struct Team: Codable {

    public var name: String
    public var members: [TeamMember]
    public let internalID: UUID

    public init(
        name: String,
        members: [TeamMember] = [],
        internalID: UUID = .init()
    ) {
        self.name = name
        self.members = members
        self.internalID = internalID
    }

}

extension Team: Comparable {

    public static func < (lhs: Team, rhs: Team) -> Bool {
        if lhs.name == rhs.name {
            return lhs.internalID.uuidString < rhs.internalID.uuidString
        } else {
            return lhs.name < rhs.name
        }
    }

}

extension Team: Hashable { }

extension Team: Identifiable {

    public var id: String { internalID.uuidString }

}
