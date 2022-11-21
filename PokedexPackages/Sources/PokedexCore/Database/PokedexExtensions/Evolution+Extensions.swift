//
//  StoredEvolution+Extensions.swift
//  Database
//
//  Created by Daniel Byon on 12/18/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Values
public extension StoredEvolution {

    var familyName: String {
        get { z_familyName! }
        set { z_familyName = newValue }
    }

    var game: Game {
        get { Game(rawValue: z_game!)! }
        set { z_game = newValue.rawValue }
    }

    var method: EvolutionMethod {
        get {
            guard let methodName = z_methodName, let methodData = z_methodData else { fatalError() }
            switch methodName {
            case "completeBattlePerformingAction":
                return .completeBattlePerformingAction(methodData)
            case "friendship":
                return .friendship
            case "levelUp":
                return .levelUp(Int(methodData)!)
            case "levelUpHoldingItem":
                return .levelUpHoldingItem(item!)
            case "levelUpInArea":
                return .levelUpInArea(methodData)
            case "levelUpKnowingMove":
                return .levelUpKnowingMove(move!)
            case "levelUpWithPartyMember":
                return .levelUpWithPartyMember(pokemon!)
            case "levelUpWithStats":
                return .levelUpWithStats(methodData)
            case "other":
                return .other(methodData)
            case "trade":
                return .trade
            case "tradeForPokemon":
                return .tradeForPokemon(pokemon!)
            case "tradeHoldingItem":
                return .tradeHoldingItem(item!)
            case "trainerAction":
                return .trainerAction(methodData)
            case "useItem":
                return .useItem(item!)
            default:
                fatalError()
            }
        }
        set {
            let (name, data) = newValue.stringsForPersistence
            z_methodName = name
            z_methodData = data
            item = newValue.item
            move = newValue.move
            pokemon = newValue.pokemon
        }
    }

    var condition: EvolutionCondition? {
        get {
            guard let name = z_conditionName, let data = z_conditionData else { return nil }
            return makeCondition(name: name, data: data)
        }
        set {
            guard let (name, data) = newValue?.stringsForPersistence else {
                z_conditionName = nil
                z_conditionData = nil
                return
            }
            z_conditionName = name
            z_conditionData = data
            if case .haveAbility(let ability) = newValue {
                self.ability = ability
            }
        }
    }

    var condition2: EvolutionCondition? {
        get {
            guard let name = z_conditionName2, let data = z_conditionData2 else { return nil }
            return makeCondition(name: name, data: data)
        }
        set {
            guard let (name, data) = newValue?.stringsForPersistence else {
                z_conditionName2 = nil
                z_conditionData2 = nil
                return
            }
            z_conditionName2 = name
            z_conditionData2 = data
            if case .haveAbility(let ability) = newValue {
                self.ability = ability
            }
        }
    }

    var from: StoredPokemonForm {
        get { z_from! }
        set { z_from = newValue }
    }
    var to: StoredPokemonForm {
        get { z_to! }
        set { z_to = newValue }
    }

    private func makeCondition(name: String, data: String) -> EvolutionCondition {
        switch name {
        case "deviceHeldUpsideDown":
            return .deviceHeldUpsideDown
        case "gender":
            return .gender(Gender(rawValue: data)!)
        case "haveAbility":
            return .haveAbility(ability!)
        case "other":
            return .other(data)
        case "partyMemberType":
            return .partyMemberType(PokemonType(rawValue: data)!)
        case "region":
            return .region(Region(rawValue: data)!)
        case "timeOfDay":
            return .timeOfDay(TimeOfDay(rawValue: data)!)
        case "weather":
            return .weather(Weather(rawValue: data)!)
        default:
            fatalError()
        }
    }

}
