//
//  Ability.swift
//  
//
//  Created by Daniel Byon on 9/22/22.
//

import Foundation

public struct Ability: Queryable {

    public typealias Filter = AbilityFilter

    public let generationIntroduced: Generation
    public let index: Int
    public let name: String
    public let descriptions: [Game: String]
    public let bulbapediaURL: URL
    public let pokemonDBURL: URL

    public init(result: StoredAbility) {
        generationIntroduced = result.generationIntroduced
        index = result.index
        name = result.name
        descriptions = Game.allCases.reduce(into: [:]) { partialResult, game in
            partialResult[game] = result.description(forGame: game)
        }
        bulbapediaURL = result.bulbapediaURL
        pokemonDBURL = result.pokemonDBURL
    }

    public init(
        generationIntroduced: Generation,
        index: Int,
        name: String,
        descriptions: [Game: String],
        bulbapediaURL: URL,
        pokemonDBURL: URL
    ) {
        self.generationIntroduced = generationIntroduced
        self.index = index
        self.name = name
        self.descriptions = descriptions
        self.bulbapediaURL = bulbapediaURL
        self.pokemonDBURL = pokemonDBURL
    }

    public subscript(game: Game) -> String? {
        descriptions[game]
    }

}

extension Ability: Codable { }

extension Ability: Hashable { }
