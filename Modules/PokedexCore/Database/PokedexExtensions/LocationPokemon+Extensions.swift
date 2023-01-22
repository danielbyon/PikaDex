//
//  StoredLocationPokemon+Extensions.swift
//  Pokedex
//
//  Created by Daniel Byon on 3/11/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Fetch Requests
extension StoredLocationPokemon {

    public static func fetchRequest(for location: StoredLocation, game: Game) -> NSFetchRequest<StoredLocationPokemon> {
        let request: NSFetchRequest<StoredLocationPokemon> = StoredLocationPokemon.fetchRequest()
        request.predicate = NSPredicate(format: "\(#keyPath(StoredLocationPokemon.z_location)) == %@ && \(#keyPath(StoredLocationPokemon.z_game)) == %@", location, game.rawValue)
        request.relationshipKeyPathsForPrefetching = [
            #keyPath(StoredLocationPokemon.z_location),
            #keyPath(StoredLocationPokemon.z_pokemon),
            #keyPath(StoredLocationPokemon.z_pokemon.z_forms)
        ]
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(StoredLocationPokemon.z_area), ascending: true),
            NSSortDescriptor(key: #keyPath(StoredLocationPokemon.z_captureMethod), ascending: true),
            NSSortDescriptor(key: #keyPath(StoredLocationPokemon.z_pokemon.z_name), ascending: true)
        ]
        return request
    }

    public static func fetchRequest(for pokemon: StoredPokemon, game: Game) -> NSFetchRequest<StoredLocationPokemon> {
        let request: NSFetchRequest<StoredLocationPokemon> = StoredLocationPokemon.fetchRequest()
        request.predicate = NSPredicate(format: "\(#keyPath(StoredLocationPokemon.z_pokemon)) == %@ && \(#keyPath(StoredLocationPokemon.z_game)) == %@", pokemon, game.rawValue)
        request.relationshipKeyPathsForPrefetching = [
            #keyPath(StoredLocationPokemon.z_location)
        ]
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(StoredLocationPokemon.z_location.z_name), ascending: true),
            NSSortDescriptor(key: #keyPath(StoredLocationPokemon.z_area), ascending: true),
            NSSortDescriptor(key: #keyPath(StoredLocationPokemon.z_captureMethod), ascending: true)
        ]
        return request
    }

}

//// MARK: - Identifiable
//extension StoredLocationPokemon: Identifiable {
//
//    public var id: String {
//        pokemon.name
//            + area
//            + captureMethod.rawValue
//            + String(describing: z_encounterRateType)
//            + String(describing: z_encounterRate)
//            + String(levelLow)
//            + String(describing: levelHigh)
//            + encounterCondition
//            + (timeOfDay ?? []).map { $0.rawValue }.joined()
//    }
//
//}

// MARK: - Properties
public extension StoredLocationPokemon {

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
        get { (value(forKeyPath: #keyPath(StoredLocationPokemon.z_levelHigh)) as? Int64)?.toInt() }
        set { setValue(newValue, forKeyPath: #keyPath(StoredLocationPokemon.z_levelHigh)) }
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
    var location: StoredLocation {
        get { z_location! }
        set { z_location = newValue }
    }
    var pokemon: StoredPokemon {
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
