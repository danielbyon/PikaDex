//
//  Move.swift
//  
//
//  Created by Daniel Byon on 9/29/22.
//

import Foundation

public struct Move: Queryable {

    public typealias Filter = MoveFilter

    public let name: String
    public let game: Game
    public let generationIntroduced: Generation
    public let index: Int
    public let type: PokemonType
    public let category: MoveCategory
    public let bulbapediaURL: URL
    public let pokemonDBURL: URL

    public let accuracy: Int?
    public let maxPP: Int?
    public let moveDescription: String
    public let power: Int?
    public let pp: Int?
    public let priority: Int
    public let targetAlly1: Bool
    public let targetAlly2: Bool
    public let targetDescription: String
    public let targetEnemy1: Bool
    public let targetEnemy2: Bool
    public let targetEnemy3: Bool
    public let targetSelf: Bool

    public init(result: StoredMove) {
        self.name = result.name
        self.game = result.game
        self.generationIntroduced = result.generationIntroduced
        self.index = result.index
        self.type = result.type
        self.category = result.category
        self.bulbapediaURL = result.bulbapediaURL
        self.pokemonDBURL = result.pokemonDBURL
        self.accuracy = result.accuracy
        self.maxPP = result.maxPP
        self.moveDescription = result.moveDescription
        self.power = result.power
        self.pp = result.pp
        self.priority = result.priority
        self.targetAlly1 = result.targetAlly1
        self.targetAlly2 = result.targetAlly2
        self.targetDescription = result.targetDescription
        self.targetEnemy1 = result.targetEnemy1
        self.targetEnemy2 = result.targetEnemy2
        self.targetEnemy3 = result.targetEnemy3
        self.targetSelf = result.targetSelf
    }

    public init(
        name: String,
        game: Game,
        generationIntroduced: Generation,
        index: Int,
        type: PokemonType,
        category: MoveCategory,
        bulbapediaURL: URL,
        pokemonDBURL: URL,
        accuracy: Int? = nil,
        maxPP: Int? = nil,
        moveDescription: String,
        power: Int? = nil,
        pp: Int? = nil,
        priority: Int,
        targetAlly1: Bool,
        targetAlly2: Bool,
        targetDescription: String,
        targetEnemy1: Bool,
        targetEnemy2: Bool,
        targetEnemy3: Bool,
        targetSelf: Bool
    ) {
        self.name = name
        self.game = game
        self.generationIntroduced = generationIntroduced
        self.index = index
        self.type = type
        self.category = category
        self.bulbapediaURL = bulbapediaURL
        self.pokemonDBURL = pokemonDBURL
        self.accuracy = accuracy
        self.maxPP = maxPP
        self.moveDescription = moveDescription
        self.power = power
        self.pp = pp
        self.priority = priority
        self.targetAlly1 = targetAlly1
        self.targetAlly2 = targetAlly2
        self.targetDescription = targetDescription
        self.targetEnemy1 = targetEnemy1
        self.targetEnemy2 = targetEnemy2
        self.targetEnemy3 = targetEnemy3
        self.targetSelf = targetSelf
    }


}

extension Move: Codable { }

extension Move: CustomDebugStringConvertible {

    public var debugDescription: String {
        [
            name,
            game.rawValue,
            "\(index)",
            type.rawValue,
            category.rawValue
        ].joined(separator: ", ")
    }

}

extension Move: Hashable { }
