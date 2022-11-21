//
//  LearnsetBreedingFather.swift
//  
//
//  Created by Daniel Byon on 10/3/22.
//

import Foundation

public struct LearnsetBreedingFather {

    public let name: String

    public init(result: StoredPokemon) {
        self.name = result.name
    }

}

extension LearnsetBreedingFather: Codable { }

extension LearnsetBreedingFather: Hashable { }
