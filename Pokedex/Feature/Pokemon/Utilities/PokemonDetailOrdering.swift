//
//  PokemonDetailOrdering.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/11/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

public final class PokemonDetailOrdering: ObservableObject {

    @Published public private(set) var sections: [PokemonDetailSection] = PokemonDetailSection.allCases {
        didSet {
            storedOrdering = try? JSONEncoder().encode(sections)
        }
    }

    @AppStorage("PokemonDetailOrdering") private var storedOrdering: Data?

    public init() {
        if let storedOrdering = storedOrdering,
           let decoded = try? JSONDecoder().decode([PokemonDetailSection].self, from: storedOrdering) {
            sections = decoded
        } else {
            sections = PokemonDetailSection.allCases
        }
    }

    public func update(from: IndexSet, to: Int) {
        sections.move(fromOffsets: from, toOffset: to)
    }

    public func reset() {
        sections = PokemonDetailSection.allCases
    }

}
