//
//  LocationPokemon.swift
//  
//
//  Created by Daniel Byon on 10/19/22.
//

import Foundation

public struct LocationPokemon: Queryable {

    public typealias Filter = LocationPokemonFilter

    public let area: String
    public let captureMethod: CaptureMethod
    public let detail: String?
    public let encounterCondition: String
    public let game: Game
    public let levelHigh: Int?
    public let levelLow: Int
    public let encounterRate: EncounterRate
    public let timeOfDay: [TimeOfDay]?

    public let location: Location
    public let pokemon: Pokemon

    public init(result: StoredLocationPokemon) {
        self.area = result.area
        self.captureMethod = result.captureMethod
        self.detail = result.detail
        self.encounterCondition = result.encounterCondition
        self.game = result.game
        self.levelHigh = result.levelHigh
        self.levelLow = result.levelLow
        self.encounterRate = result.encounterRate
        self.timeOfDay = result.timeOfDay

        self.location = .init(result: result.location)
        self.pokemon = .init(result: result.pokemon)
    }

}

extension LocationPokemon: Codable { }

extension LocationPokemon: Hashable { }
