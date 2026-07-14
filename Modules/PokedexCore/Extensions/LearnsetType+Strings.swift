//
//  LearnsetType+Strings.swift
//  Pokedex
//
//  Created by Daniel Byon on 2/17/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

extension LearnsetType {

    public static func allCases(for game: Game) -> [LearnsetType] {
        var types: [LearnsetType] = [.level, .machine]
        if game.datasetFeatures.showsBreedingLearnsets {
            types.append(.breeding)
        }
        if game.datasetFeatures.showsTutoringLearnsets {
            types.append(.tutoring)
        }
        return types
    }

    public static func allTitles(for game: Game) -> [String] {
        allCases(for: game).map { $0.title }
    }

    public var title: String {
        switch self {
        case .level:
            return "Level"
        case .machine:
            return "Machine"
        case .breeding:
            return "Breeding"
        case .tutoring:
            return "Tutoring"
        }
    }

}
