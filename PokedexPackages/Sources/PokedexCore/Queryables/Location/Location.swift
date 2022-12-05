//
//  Location.swift
//  
//
//  Created by Daniel Byon on 10/17/22.
//

import Foundation

public struct Location: Queryable {

    public typealias Filter = LocationFilter

    public let name: String
    public let game: Game
    public let region: Region
    public let maps: [LocationMap]
    public let bulbapediaURL: URL?
    public let pokemonDBURL: URL?

    public var hasExternalLinks: Bool {
        bulbapediaURL != nil || pokemonDBURL != nil
    }

    public init(result: StoredLocation) {
        self.name = result.name
        self.game = result.game
        self.region = result.region
        self.maps = result.maps
            .map(LocationMap.init)
            .sorted()
        self.bulbapediaURL = result.bulbapediaURL
        self.pokemonDBURL = result.pokemonDBURL
    }

    public init(
        name: String,
        game: Game,
        region: Region,
        maps: [LocationMap],
        bulbapediaURL: URL?,
        pokemonDBURL: URL?
    ) {
        self.name = name
        self.game = game
        self.region = region
        self.maps = maps
        self.bulbapediaURL = bulbapediaURL
        self.pokemonDBURL = pokemonDBURL
    }

}

extension Location: Codable { }

extension Location: Hashable { }
