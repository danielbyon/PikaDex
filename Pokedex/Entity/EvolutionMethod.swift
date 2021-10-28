//
//  EvolutionMethod.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/11/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

public enum EvolutionMethod {

    case completeBattlePerformingAction(String)
    case friendship
    case levelUp(Int)
    case levelUpHoldingItem(Item)
    case levelUpInArea(String)
    case levelUpKnowingMove(Move)
    case levelUpWithPartyMember(StoredPokemon)
    case levelUpWithStats(String)
    case other(String)
    case trade
    case tradeForPokemon(StoredPokemon)
    case tradeHoldingItem(Item)
    case trainerAction(String)
    case useItem(Item)

}

public extension EvolutionMethod {

    var stringsForPersistence: (name: String, data: String) {
        switch self {
        case .completeBattlePerformingAction(let string):
            return ("completeBattlePerformingAction", string)
        case .friendship:
            return ("friendship", "")
        case .levelUp(let level):
            return ("levelUp", String(describing: level))
        case .levelUpHoldingItem:
            return ("levelUpHoldingItem", "")
        case .levelUpInArea(let string):
            return ("levelUpInArea", string)
        case .levelUpKnowingMove:
            return ("levelUpKnowingMove", "")
        case .levelUpWithPartyMember:
            return ("levelUpWithPartyMember", "")
        case .levelUpWithStats(let string):
            return ("levelUpWithStats", string)
        case .other(let string):
            return ("other", string)
        case .trade:
            return ("trade", "")
        case .tradeForPokemon:
            return ("tradeForPokemon", "")
        case .tradeHoldingItem:
            return ("tradeHoldingItem", "")
        case .trainerAction(let string):
            return ("trainerAction", string)
        case .useItem:
            return ("useItem", "")
        }
    }

    var item: Item? {
        switch self {
        case .levelUpHoldingItem(let item),
             .tradeHoldingItem(let item),
             .useItem(let item):
            return item
        case .completeBattlePerformingAction,
             .friendship,
             .levelUp,
             .levelUpInArea,
             .levelUpKnowingMove,
             .levelUpWithPartyMember,
             .levelUpWithStats,
             .other,
             .trade,
             .tradeForPokemon,
             .trainerAction:
            return nil
        }
    }

    var move: Move? {
        switch self {
        case .levelUpKnowingMove(let move):
            return move
        case .completeBattlePerformingAction,
             .friendship,
             .levelUp,
             .levelUpHoldingItem,
             .levelUpInArea,
             .levelUpWithPartyMember,
             .levelUpWithStats,
             .other,
             .trade,
             .tradeForPokemon,
             .tradeHoldingItem,
             .trainerAction,
             .useItem:
            return nil
        }
    }

    var pokemon: StoredPokemon? {
        switch self {
        case .levelUpWithPartyMember(let pokemon),
             .tradeForPokemon(let pokemon):
            return pokemon
        case .completeBattlePerformingAction,
             .friendship,
             .levelUp,
             .levelUpHoldingItem,
             .levelUpInArea,
             .levelUpKnowingMove,
             .levelUpWithStats,
             .other,
             .trade,
             .tradeHoldingItem,
             .trainerAction,
             .useItem:
            return nil
        }
    }

}
