//
//  LearnsetType+Strings.swift
//  Pokedex
//
//  Created by Daniel Byon on 2/17/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

extension LearnsetType {

    static func allCases(for game: Game) -> [LearnsetType] {
        var types: [LearnsetType] = [.level, .machine]
        if game.hasBreeding {
            types.append(.breed)
        }
        if game.hasTutoring {
            types.append(.tutor)
        }
        return types
    }

    static func allTitles(for game: Game) -> [String] {
        allCases(for: game).map { $0.title }
    }

    var title: String {
        switch self {
        case .level:
            return "Level"
        case .machine:
            return "Machine"
        case .breed:
            return "Breeding"
        case .tutor:
            return "Tutoring"
        }
    }

}
