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
    var ability: String
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
        ability: String,
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

    init(pokemonForm: PokemonForm, game: Game) {
        self.pokemon = pokemonForm.pokemon.name
        self.formName = pokemonForm.name
        self.nickname = ""
        self.level = 100
        self.hp = .init(baseValue: pokemonForm.baseStats.hp, ev: 0, iv: 0)
        self.attack = .init(baseValue: pokemonForm.baseStats.attack, ev: 0, iv: 0)
        self.defense = .init(baseValue: pokemonForm.baseStats.defense, ev: 0, iv: 0)
        self.specialAttack = .init(baseValue: pokemonForm.baseStats.specialAttack, ev: 0, iv: 0)
        self.specialDefense = .init(baseValue: pokemonForm.baseStats.specialDefense, ev: 0, iv: 0)
        self.speed = .init(baseValue: pokemonForm.baseStats.speed, ev: 0, iv: 0)
        self.ability = pokemonForm.primaryAbility.name
        self.game = game
        self.internalID = UUID()
    }

}

extension TeamMember: Equatable {

    static func == (lhs: TeamMember, rhs: TeamMember) -> Bool {
        lhs.internalID == rhs.internalID
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
