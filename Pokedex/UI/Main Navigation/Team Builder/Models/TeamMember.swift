//
//  TeamMember.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/22/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

struct TeamMember: Codable {

    var pokemon: String
    var formName: String
    var nickname: String
    var level: Int

    var hp: Stat
    var attack: Stat
    var defense: Stat
    var specialAttack: Stat
    var specialDefense: Stat
    var speed: Stat

    var move1: String?
    var move2: String?
    var move3: String?
    var move4: String?
    var nature: String?
    var ability: String?
    var heldItem: String?
    var happiness: Int = 255
    var isShiny: Bool = false
    var gender: Gender = .unspecified

    let game: Game
    let internalID: UUID

    var allStats: [Stat] { [hp, attack, defense, specialAttack, specialDefense, speed].compactMap { $0 } }

    struct Stat: Codable {
        let baseValue: Int
        var ev: Int
        var iv: Int

        var value: Int { baseValue } // TODO: compute
    }

    init(
        pokemon: String,
        formName: String,
        nickname: String,
        level: Int,
        hp: Stat,
        attack: Stat,
        defense: Stat,
        specialAttack: Stat,
        specialDefense: Stat,
        speed: Stat,
        move1: String?,
        move2: String?,
        move3: String?,
        move4: String?,
        nature: String?,
        ability: String?,
        heldItem: String?,
        happiness: Int,
        isShiny: Bool,
        gender: Gender,
        game: Game,
        internalID: UUID) {
        self.pokemon = pokemon
        self.formName = formName
        self.nickname = nickname
        self.level = level
        self.hp = hp
        self.attack = attack
        self.defense = defense
        self.specialAttack = specialAttack
        self.specialDefense = specialDefense
        self.speed = speed
        self.move1 = move1
        self.move2 = move2
        self.move3 = move3
        self.move4 = move4
        self.nature = nature
        self.ability = ability
        self.heldItem = heldItem
        self.happiness = happiness
        self.isShiny = isShiny
        self.gender = gender
        self.game = game
        self.internalID = internalID
    }

}

extension TeamMember: Equatable {

    static func == (lhs: TeamMember, rhs: TeamMember) -> Bool {
        lhs.internalID == rhs.internalID
    }

}

extension TeamMember: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(pokemon)
        hasher.combine(formName)
        hasher.combine(nickname)
        hasher.combine(level)
        hasher.combine(hp)
        hasher.combine(attack)
        hasher.combine(defense)
        hasher.combine(specialAttack)
        hasher.combine(specialDefense)
        hasher.combine(speed)
        hasher.combine(move1)
        hasher.combine(move2)
        hasher.combine(move3)
        hasher.combine(move4)
        hasher.combine(nature)
        hasher.combine(ability)
        hasher.combine(heldItem)
        hasher.combine(happiness)
        hasher.combine(isShiny)
        hasher.combine(gender)
        hasher.combine(game)
        hasher.combine(internalID)
    }

}

extension TeamMember: Identifiable {

    var id: String { internalID.uuidString }

}

extension TeamMember.Stat: Equatable {

    static func == (lhs: TeamMember.Stat, rhs: TeamMember.Stat) -> Bool {
        lhs.baseValue == rhs.baseValue
            && lhs.ev == rhs.ev
            && lhs.iv == rhs.iv
    }

}

extension TeamMember.Stat: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(baseValue)
        hasher.combine(ev)
        hasher.combine(iv)
    }

}
