//
//  Evolution+Extensions.swift
//  Database
//
//  Created by Daniel Byon on 12/18/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Values
public extension Evolution {

    var familyName: String {
        get { z_familyName! }
        set { z_familyName = newValue }
    }

    var game: Game {
        get { Game(rawValue: z_game!)! }
        set { z_game = newValue.rawValue }
    }

    var name: String {
        get { z_name! }
        set { z_name = newValue }
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
        set {
            guard let (name, data) = newValue?.stringsForPersistence else {
                z_conditionName = nil
                z_conditionData = nil
                ability = nil
                return
            }
            z_conditionName = name
            z_conditionData = data
            ability = newValue?.ability
        }
    }

    var from: PokemonForm {
        get { z_from! }
        set { z_from = newValue }
    }
    var to: PokemonForm {
        get { z_to! }
        set { z_to = newValue }
    }

}

// MARK: - Identifiable
extension Evolution: Identifiable {

    public var id: String { "\(from.name)-\(to.name)" }

}
