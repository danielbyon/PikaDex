//
//  File.swift
//  
//
//  Created by Daniel Byon on 12/4/19.
//

import Foundation

public struct TypeEffectiveness {

    public let primary: PokemonType
    public let secondary: PokemonType?

    public enum Kind: String, CaseIterable, Identifiable {

        case offense = "Offense"
        case defense = "Defense"

        public var id: String { rawValue }

    }

    public init(primary: PokemonType, secondary: PokemonType?) {
        self.primary = primary
        self.secondary = secondary
    }

    public subscript(offense offenseType: PokemonType, generation: Generation) -> Double {
        offense(for: offenseType, generation: generation)
    }

    public subscript(defense defenseType: PokemonType, generation: Generation) -> Double {
        defense(for: defenseType, generation: generation)
    }

    public func offense(for opposing: PokemonType, generation: Generation) -> Double {
        var retVal = primary.offense(for: opposing, generation: generation)
        if let secondary = secondary {
            retVal *= secondary.offense(for: opposing, generation: generation)
        }
        return retVal
    }

    public func defense(for opposing: PokemonType, generation: Generation) -> Double {
        var retVal = primary.defense(for: opposing, generation: generation)
        if let secondary = secondary {
            retVal *= secondary.defense(for: opposing, generation: generation)
        }
        return retVal
    }

    public func groupedOffenseTypes(generation: Generation) -> [TypeEffectivenessGroup] {
        var grouped: [Double: [PokemonType]] = [:]
        PokemonType.allCases.forEach { type in
            let value = self.offense(for: type, generation: generation)
            guard value >= 0 else { return }
            if let existingGroup = grouped[value] {
                grouped[value] = existingGroup + [type]
            } else {
                grouped[value] = [type]
            }
        }
        return grouped.map { TypeEffectivenessGroup(effectiveness: $0.key, types: $0.value) }
    }

    public func groupedDefenseTypes(generation: Generation) -> [TypeEffectivenessGroup] {
        var grouped: [Double: [PokemonType]] = [:]
        PokemonType.allCases.forEach { type in
            let value = self.defense(for: type, generation: generation)
            guard value >= 0 else { return }
            if let existingGroup = grouped[value] {
                grouped[value] = existingGroup + [type]
            } else {
                grouped[value] = [type]
            }
        }
        return grouped.map { TypeEffectivenessGroup(effectiveness: $0.key, types: $0.value) }
    }

}
