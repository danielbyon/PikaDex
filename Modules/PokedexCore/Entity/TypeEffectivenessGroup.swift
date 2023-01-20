//
//  TypeEffectivenessGroup.swift
//  
//
//  Created by Daniel Byon on 12/18/19.
//

import Foundation

public struct TypeEffectivenessGroup {

    public let effectiveness: Double
    public let types: [PokemonType]

    public init(effectiveness: Double, types: [PokemonType]) {
        self.effectiveness = effectiveness
        self.types = types
    }

}

extension TypeEffectivenessGroup: Equatable {

    public static func == (lhs: TypeEffectivenessGroup, rhs: TypeEffectivenessGroup) -> Bool {
        lhs.effectiveness == rhs.effectiveness
            && lhs.types == rhs.types
    }

}

extension TypeEffectivenessGroup: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(effectiveness)
        hasher.combine(types)
    }

}

extension TypeEffectivenessGroup: Identifiable {

    public var id: Double { effectiveness }

}
