//
//  TeamMember.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/22/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

public struct TeamMember: Codable {

    public var pokemon: String
    public var formName: String
    public var nickname: String
    public var level: Int

    public var hp: Stat
    public var attack: Stat
    public var defense: Stat
    public var specialAttack: Stat
    public var specialDefense: Stat
    public var speed: Stat

    public var move1: String?
    public var move2: String?
    public var move3: String?
    public var move4: String?
    public var nature: String?
    public var ability: String?
    public var heldItem: String?
    public var happiness: Int
    public var isShiny: Bool
    public var gender: Gender

    public let game: Game
    public let internalID: UUID

    public var allStats: [Stat] { [hp, attack, defense, specialAttack, specialDefense, speed].compactMap { $0 } }

    public var calculatedHP: Int {
        hp.isCalculated
        ? StatCalculator.calculateStat(
            statType: .hp,
            baseValue: hp.baseValue,
            iv: hp.iv,
            ev: hp.ev,
            level: Int(level),
            nature: resolvedNature,
            game: game
        )
        : hp.value
    }
    public var calculatedAttack: Int {
        attack.isCalculated
        ? StatCalculator.calculateStat(
            statType: .attack,
            baseValue: attack.baseValue,
            iv: attack.iv,
            ev: attack.ev,
            level: Int(level),
            nature: resolvedNature,
            game: game
        )
        : attack.value
    }
    public var calculatedDefense: Int {
        defense.isCalculated
        ? StatCalculator.calculateStat(
            statType: .defense,
            baseValue: defense.baseValue,
            iv: defense.iv,
            ev: defense.ev,
            level: Int(level),
            nature: resolvedNature,
            game: game
        )
        : defense.value
    }
    public var calculatedSpecialAttack: Int {
        specialAttack.isCalculated
        ? StatCalculator.calculateStat(
            statType: .specialAttack,
            baseValue: specialAttack.baseValue,
            iv: specialAttack.iv,
            ev: specialAttack.ev,
            level: Int(level),
            nature: resolvedNature,
            game: game
        )
        : specialAttack.value
    }
    public var calculatedSpecialDefense: Int {
        specialDefense.isCalculated
        ? StatCalculator.calculateStat(
            statType: .specialDefense,
            baseValue: specialDefense.baseValue,
            iv: specialDefense.iv,
            ev: specialDefense.ev,
            level: Int(level),
            nature: resolvedNature,
            game: game
        )
        : specialDefense.value
    }
    public var calculatedSpeed: Int {
        speed.isCalculated
        ? StatCalculator.calculateStat(
            statType: .speed,
            baseValue: speed.baseValue,
            iv: speed.iv,
            ev: speed.ev,
            level: Int(level),
            nature: resolvedNature,
            game: game
        )
        : speed.value
    }

    private var resolvedNature: Nature {
        guard let nature else { return .hardy }
        return Nature[nature] ?? .hardy
    }

    public struct Stat: Codable {

        public let baseValue: Int
        public var ev: Int
        public var iv: Int
        public var isCalculated: Bool
        public var value: Int

//        private enum CodingKeys: String, CodingKey {
//            case baseValue
//            case ev
//            case iv
//            case isCalculated
//            case value
//        }

        public init(
            baseValue: Int,
            ev: Int,
            iv: Int,
            isCalculated: Bool = true,
            value: Int = 0
        ) {
            self.baseValue = baseValue
            self.ev = ev
            self.iv = iv
            self.isCalculated = isCalculated
            self.value = value
        }

//        public init(from decoder: Decoder) throws {
//            let container = try decoder.container(keyedBy: CodingKeys.self)
//            baseValue = try container.decode(Int.self, forKey: .baseValue)
//            ev = try container.decode(Int.self, forKey: .ev)
//            iv = try container.decode(Int.self, forKey: .iv)
//            isCalculated = try container.decodeIfPresent(Bool.self, forKey: .isCalculated) ?? true
//            value = try container.decodeIfPresent(Int.self, forKey: .value) ?? 0
//        }
    }

    public init(
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
        happiness: Int = 255,
        isShiny: Bool = false,
        gender: Gender = .unspecified,
        game: Game,
        internalID: UUID
    ) {
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

    public init(pokemonForm: PokemonDetailForm) {
        self.init(
            pokemon: pokemonForm.pokemonName,
            formName: pokemonForm.name,
            nickname: "",
            level: 100,
            hp: .init(baseValue: pokemonForm.baseStats.hp, ev: 0, iv: 0, isCalculated: true, value: 0),
            attack: .init(baseValue: pokemonForm.baseStats.attack, ev: 0, iv: 0, isCalculated: true, value: 0),
            defense: .init(baseValue: pokemonForm.baseStats.defense, ev: 0, iv: 0, isCalculated: true, value: 0),
            specialAttack: .init(baseValue: pokemonForm.baseStats.specialAttack, ev: 0, iv: 0, isCalculated: true, value: 0),
            specialDefense: .init(baseValue: pokemonForm.baseStats.specialDefense, ev: 0, iv: 0, isCalculated: true, value: 0),
            speed: .init(baseValue: pokemonForm.baseStats.speed, ev: 0, iv: 0, isCalculated: true, value: 0),
            move1: nil,
            move2: nil,
            move3: nil,
            move4: nil,
            nature: nil,
            ability: pokemonForm.hasAbilities ? pokemonForm.primaryAbility?.name : nil,
            heldItem: nil,
            game: pokemonForm.game,
            internalID: .init()
        )
    }

}

extension TeamMember: Hashable { }

extension TeamMember: Identifiable {

    public var id: String { internalID.uuidString }

}

extension TeamMember.Stat: Hashable { }
