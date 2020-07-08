//
//  LocationPokemon+Extensions.swift
//  Pokedex
//
//  Created by Daniel Byon on 3/11/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Fetch Requests
extension LocationPokemon {

    static func fetchRequest(for location: Location, game: Game) -> NSFetchRequest<LocationPokemon> {
        let request: NSFetchRequest<LocationPokemon> = LocationPokemon.fetchRequest()
        request.predicate = NSPredicate(format: "\(#keyPath(LocationPokemon.z_location)) == %@ && \(#keyPath(LocationPokemon.z_game)) == %@", location, game.rawValue)
        request.relationshipKeyPathsForPrefetching = [
            #keyPath(LocationPokemon.z_location),
            #keyPath(LocationPokemon.z_pokemon),
            #keyPath(LocationPokemon.z_pokemon.z_forms)
        ]
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(LocationPokemon.z_area), ascending: true),
            NSSortDescriptor(key: #keyPath(LocationPokemon.z_captureMethod), ascending: true),
            NSSortDescriptor(key: #keyPath(LocationPokemon.z_pokemon.z_name), ascending: true)
        ]
        return request
    }

    static func fetchRequest(for pokemon: Pokemon, game: Game) -> NSFetchRequest<LocationPokemon> {
        let request: NSFetchRequest<LocationPokemon> = LocationPokemon.fetchRequest()
        request.predicate = NSPredicate(format: "\(#keyPath(LocationPokemon.z_pokemon)) == %@ && \(#keyPath(LocationPokemon.z_game)) == %@", pokemon, game.rawValue)
        request.relationshipKeyPathsForPrefetching = [
            #keyPath(LocationPokemon.z_location)
        ]
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(LocationPokemon.z_location.z_name), ascending: true),
            NSSortDescriptor(key: #keyPath(LocationPokemon.z_area), ascending: true),
            NSSortDescriptor(key: #keyPath(LocationPokemon.z_captureMethod), ascending: true)
        ]
        return request
    }

}

// MARK: - Identifiable
extension LocationPokemon: Identifiable {

    public var id: String {
        pokemon.name
            + area
            + captureMethod.rawValue
            + String(describing: z_encounterRateType)
            + String(describing: z_encounterRate)
            + String(levelLow)
            + String(describing: levelHigh)
            + encounterCondition
            + (timeOfDay ?? []).map { $0.rawValue }.joined()
    }

}

// MARK: - Properties
public extension LocationPokemon {

    var area: String {
        get { z_area! }
        set { z_area = newValue }
    }

    var captureMethod: CaptureMethod {
        get { CaptureMethod(rawValue: z_captureMethod!)! }
        set { z_captureMethod = newValue.rawValue }
    }

    var encounterCondition: String {
        get { z_encounterCondition! }
        set { z_encounterCondition = newValue }
    }

    var game: Game {
        get { Game(rawValue: z_game!)! }
        set { z_game = newValue.rawValue }
    }

    var levelHigh: Int? {
        get { (value(forKeyPath: #keyPath(LocationPokemon.z_levelHigh)) as? Int64)?.toInt() }
        set { setValue(newValue, forKeyPath: #keyPath(LocationPokemon.z_levelHigh)) }
    }

    var levelLow: Int {
        get { Int(z_levelLow) }
        set { z_levelLow = Int64(newValue) }
    }

    var encounterRate: EncounterRate {
        get {
            EncounterRate(
                rateType: EncounterRateType(rawValue: z_encounterRateType!)!,
                rate: z_encounterRate!)
        }
        set {
            switch newValue {
            case .percent(let rarity):
                z_encounterRateType = EncounterRateType.percent.rawValue
                z_encounterRate = "\(rarity)"
            case .rarity(let rarity):
                z_encounterRateType = EncounterRateType.rarity.rawValue
                z_encounterRate = rarity.rawValue
            case .unknown:
                z_encounterRateType = EncounterRateType.unknown.rawValue
                z_encounterRate = ""
            }
        }
    }
    var location: Location {
        get { z_location! }
        set { z_location = newValue }
    }
    var pokemon: Pokemon {
        get { z_pokemon! }
        set { z_pokemon = newValue}
    }
    var timeOfDay: [TimeOfDay]? {
        get {
            z_timeOfDay?
                .components(separatedBy: ",")
                .map { TimeOfDay(rawValue: $0)! }
        }
        set { z_timeOfDay = newValue?.map { $0.rawValue }.joined(separator: ",") }
    }

}
