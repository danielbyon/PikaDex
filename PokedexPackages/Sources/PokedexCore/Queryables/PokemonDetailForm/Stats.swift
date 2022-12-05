//
//  Stats.swift
//  
//
//  Created by Daniel Byon on 9/21/22.
//

import Foundation

public struct Stats {

    public let attack: Int
    public let defense: Int
    public let hp: Int
    public let specialAttack: Int
    public let specialDefense: Int
    public let speed: Int

    init(_ result: StoredStats) {
        attack = result.attack
        defense = result.defense
        hp = result.hp
        specialAttack = result.specialAttack
        specialDefense = result.specialDefense
        speed = result.speed
    }

    public init(
        attack: Int,
        defense: Int,
        hp: Int,
        specialAttack: Int,
        specialDefense: Int,
        speed: Int
    ) {
        self.attack = attack
        self.defense = defense
        self.hp = hp
        self.specialAttack = specialAttack
        self.specialDefense = specialDefense
        self.speed = speed
    }

}

extension Stats: Codable { }

extension Stats: Hashable { }
