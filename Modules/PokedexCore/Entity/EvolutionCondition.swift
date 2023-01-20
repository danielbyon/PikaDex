//
//  EvolutionCondition.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/11/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

public enum EvolutionCondition {
    
    case deviceHeldUpsideDown
    case gender(Gender)
    case haveAbility(StoredAbility)
    case other(String)
    case partyMemberType(PokemonType)
    case region(Region)
    case timeOfDay(TimeOfDay)
    case weather(Weather)

}

extension EvolutionCondition {

    var stringsForPersistence: (name: String, data: String) {
        switch self {
        case .deviceHeldUpsideDown:
            return ("deviceHeldUpsideDown", "")
        case .gender(let gender):
            return ("gender", gender.rawValue)
        case .haveAbility:
            return ("haveAbility", "")
        case .other(let string):
            return ("other", string)
        case .partyMemberType(let type):
            return ("partyMemberType", type.rawValue)
        case .region(let region):
            return ("region", region.rawValue)
        case .timeOfDay(let timeOfDay):
            return ("timeOfDay", timeOfDay.rawValue)
        case .weather(let weather):
            return ("weather", weather.rawValue)
        }
    }

    var ability: StoredAbility? {
        switch self {
        case .haveAbility(let ability):
            return ability
        case .deviceHeldUpsideDown,
             .gender,
             .other,
             .partyMemberType,
             .region,
             .timeOfDay,
             .weather:
            return nil
        }
    }

}
