//
//  TeamMemberViewModel.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/22/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI
import Combine

class TeamMemberViewModel: ObservableObject {

    @Published var nickname = ""
    @Published var level = 100.0
    @Published var nature: Nature = .hardy
    @Published var ability: Ability?
    @Published var heldItem: Item?
    @Published var happiness = 255
    @Published var isShiny = false
    @Published var gender: Gender = .unspecified

    @Published var hpIV = 0
    @Published var hpEV = 0
    @Published var attackIV = 0
    @Published var attackEV = 0
    @Published var defenseIV = 0
    @Published var defenseEV = 0
    @Published var specialAttackIV = 0
    @Published var specialAttackEV = 0
    @Published var specialDefenseIV = 0
    @Published var specialDefenseEV = 0
    @Published var speedIV = 0
    @Published var speedEV = 0

    @Published var move1: Move?
    @Published var move2: Move?
    @Published var move3: Move?
    @Published var move4: Move?

    var calculatedHP: Int { StatCalculator.calculateStat(statType: .hp, baseValue: baseHP, iv: hpIV, ev: hpEV, level: Int(level), nature: nature, game: game) }
    var calculatedAttack: Int { StatCalculator.calculateStat(statType: .attack, baseValue: baseAttack, iv: attackIV, ev: attackEV, level: Int(level), nature: nature, game: game) }
    var calculatedDefense: Int { StatCalculator.calculateStat(statType: .defense, baseValue: baseDefense, iv: defenseIV, ev: defenseEV, level: Int(level), nature: nature, game: game) }
    var calculatedSpecialAttack: Int { StatCalculator.calculateStat(statType: .specialAttack, baseValue: baseSpecialAttack, iv: specialAttackIV, ev: specialAttackEV, level: Int(level), nature: nature, game: game) }
    var calculatedSpecialDefense: Int { StatCalculator.calculateStat(statType: .specialDefense, baseValue: baseSpecialDefense, iv: specialDefenseIV, ev: specialDefenseEV, level: Int(level), nature: nature, game: game) }
    var calculatedSpeed: Int { StatCalculator.calculateStat(statType: .speed, baseValue: baseSpeed, iv: speedIV, ev: speedEV, level: Int(level), nature: nature, game: game) }

    var ivRange: Range<Int> {
        if game.generation < 3 {
            return 0..<16
        } else {
            return 0..<32
        }
    }

    let pokemonForm: PokemonForm
    let baseHP: Int
    let baseAttack: Int
    let baseDefense: Int
    let baseSpecialAttack: Int
    let baseSpecialDefense: Int
    let baseSpeed: Int
    let game: Game
    let internalID: UUID

    init(teamMember: TeamMember) {
        let pokemon = Pokemon.generate(withName: teamMember.pokemon, game: teamMember.game)
        if let form = pokemon.forms.first(where: { $0.name == teamMember.formName }) {
            self.pokemonForm = form
        } else {
            self.pokemonForm = pokemon.defaultForm
        }
        self.nickname = teamMember.nickname
        self.level = Double(teamMember.level)
        self.baseHP = teamMember.hp.baseValue
        self.baseAttack = teamMember.attack.baseValue
        self.baseDefense = teamMember.defense.baseValue
        self.baseSpecialAttack = teamMember.specialAttack.baseValue
        self.baseSpecialDefense = teamMember.specialDefense.baseValue
        self.baseSpeed = teamMember.speed.baseValue
        self.hpIV = teamMember.hp.iv
        self.hpEV = teamMember.hp.ev
        self.attackIV = teamMember.attack.iv
        self.attackEV = teamMember.attack.ev
        self.defenseIV = teamMember.defense.iv
        self.defenseEV = teamMember.defense.ev
        self.specialAttackIV = teamMember.specialAttack.iv
        self.specialAttackEV = teamMember.specialAttack.ev
        self.specialDefenseIV = teamMember.specialDefense.iv
        self.specialDefenseEV = teamMember.specialDefense.ev
        self.speedIV = teamMember.speed.iv
        self.speedEV = teamMember.speed.ev
        if let moveName = teamMember.move1 {
            self.move1 = Move.fetch(withName: moveName, game: teamMember.game)
        }
        if let moveName = teamMember.move2 {
            self.move2 = Move.fetch(withName: moveName, game: teamMember.game)
        }
        if let moveName = teamMember.move3 {
            self.move3 = Move.fetch(withName: moveName, game: teamMember.game)
        }
        if let moveName = teamMember.move4 {
            self.move4 = Move.fetch(withName: moveName, game: teamMember.game)
        }
        if let natureName = teamMember.nature {
            self.nature = Nature[natureName] ?? .hardy
        } else {
            self.nature = .hardy
        }
        if let abilityName = teamMember.ability, teamMember.game.hasAbilities {
            self.ability = Ability.generate(withName: abilityName)
        } else {
            self.ability = nil
        }
        if let itemName = teamMember.heldItem {
            self.heldItem = Item.fetch(withName: itemName, game: teamMember.game)
        } else {
            self.heldItem = nil
        }
        self.happiness = teamMember.happiness
        self.isShiny = teamMember.isShiny
        self.gender = teamMember.gender
        self.game = teamMember.game
        self.internalID = teamMember.internalID
    }

    func remainingEVRange(forStatType statType: StatType) -> Range<Int> {
        if game.generation < 3 {
            return 0..<32
        } else {
            var endValue = 510
            if statType != .hp {
                endValue -= hpEV
            }
            if statType != .attack {
                endValue -= attackEV
            }
            if statType != .defense {
                endValue -= defenseEV
            }
            if statType != .specialAttack {
                endValue -= specialAttackEV
            }
            if statType != .specialDefense {
                endValue -= specialDefenseEV
            }
            if statType != .speed {
                endValue -= speedEV
            }

            let minimumEndValue: Int
            if game.generation < 6 {
                minimumEndValue = 255
            } else {
                minimumEndValue = 252
            }

            return 0..<(min(minimumEndValue, endValue) + 1) // Add one for ..< range
        }
    }

    func makeTeamMember() -> TeamMember {
        let baseStats = pokemonForm.baseStats
        return TeamMember(
            pokemon: pokemonForm.pokemon.name,
            formName: pokemonForm.name,
            nickname: nickname,
            level: Int(level),
            hp: .init(baseValue: baseStats.hp, ev: hpEV, iv: hpIV),
            attack: .init(baseValue: baseStats.attack, ev: attackEV, iv: attackIV),
            defense: .init(baseValue: baseStats.defense, ev: defenseEV, iv: defenseIV),
            specialAttack: .init(baseValue: baseStats.specialAttack, ev: specialAttackEV, iv: specialAttackIV),
            specialDefense: .init(baseValue: baseStats.specialDefense, ev: specialDefenseEV, iv: specialDefenseIV),
            speed: .init(baseValue: baseStats.speed, ev: speedEV, iv: speedIV),
            move1: move1?.name,
            move2: move2?.name,
            move3: move3?.name,
            move4: move4?.name,
            nature: nature.name,
            ability: ability?.name,
            heldItem: heldItem?.name,
            happiness: happiness,
            isShiny: isShiny,
            gender: gender,
            game: game,
            internalID: internalID)
    }

}

extension TeamMemberViewModel: Identifiable {

    var id: String { internalID.uuidString }

}
