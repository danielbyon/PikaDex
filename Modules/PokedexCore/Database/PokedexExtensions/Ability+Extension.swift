//
//  StoredAbility+Extension.swift
//  Database
//
//  Created by Daniel Byon on 12/18/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Fetch Requests
public extension StoredAbility {

    static func allFetchRequest(for game: Game) -> NSFetchRequest<StoredAbility> {
        let request: NSFetchRequest<StoredAbility> = StoredAbility.fetchRequest()
        if let generation = game.metadata?.generation {
            request.predicate = NSPredicate(format: "\(#keyPath(StoredAbility.z_generationIntroduced)) <= %d", generation.rawValue)
        } else {
            assert(game.isNational)
            request.predicate = nil
        }
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(StoredAbility.z_name), ascending: true)]
        return request
    }

    static func fetchRequest(forName name: String) -> NSFetchRequest<StoredAbility> {
        let request: NSFetchRequest<StoredAbility> = StoredAbility.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "\(#keyPath(StoredAbility.z_name)) LIKE[cd] %@", name)
        request.returnsObjectsAsFaults = false
        return request
    }

}

// MARK: - CanonicallyNamed
extension StoredAbility: CanonicallyNamed {

    public var canonicalName: String { z_canonicalName ?? _missingString }

}

//// MARK: - Identifiable
//extension StoredAbility: Identifiable {
//
//    public var id: String { name }
//
//}

// MARK: - Properties
public extension StoredAbility {

    subscript(game: Game) -> String? {
        get { description(forGame: game) }
        set { setDescription(newValue, forGame: game) }
    }

    private var fallbackDescriptionLatestFirst: String? {
        // If this fails, something is wrong in the data pipeline. We should not
        // have an Ability without at least one description.
        Game.selectableGames
            .lazy
            .compactMap { self.description(forGame: $0) }
            .first
    }

    func resolvedDescription(forGame game: Game) -> String? {
        if game.isNational {
            return description(forGame: game)
        }
        guard let generation = game.metadata?.generation,
              generation >= generationIntroduced else {
            return fallbackDescriptionLatestFirst
        }
        return description(forGame: game)
    }

}

// MARK: - Values
public extension StoredAbility {

    var bulbapediaURL: URL {
        get { URL(string: z_bulbapediaURL!)! }
        set { z_bulbapediaURL = newValue.absoluteString }
    }
    var generationIntroduced: Generation {
        get { Generation(rawValue: Int(z_generationIntroduced))! }
        set { z_generationIntroduced = Int16(newValue.rawValue) }
    }
    var index: Int {
        get { Int(z_index) }
        set { z_index = Int16(newValue) }
    }
    var name: String {
        get { z_name! }
        set { z_name = newValue; z_canonicalName = newValue.normalizedForSearch }
    }
    var pokemonDBURL: URL {
        get { URL(string: z_pokemonDBURL!)! }
        set { z_pokemonDBURL = newValue.absoluteString }
    }

    func description(forGame game: Game) -> String? {
        guard game.isNational || game.metadata?.mechanics.hasAbilities == true else { return nil }
        return value(forKeyPath: descriptionKeyPath(forGame: game)) as? String
    }

    func setDescription(_ description: String?, forGame game: Game) {
        guard game.isNational || game.metadata?.mechanics.hasAbilities == true else { return }
        setValue(description, forKeyPath: descriptionKeyPath(forGame: game))
    }

}

// MARK: - Database Support
private extension StoredAbility {

    func descriptionKeyPath(forGame game: Game) -> String {
        switch game {
        case .red,
             .blue,
             .yellow,
             .gold,
             .silver,
             .crystal:
            assertionFailure()
            return descriptionKeyPath(forGame: Game.defaultReleasedGame)
        case .ruby: return "z_ruby"
        case .sapphire: return "z_sapphire"
        case .emerald: return "z_emerald"
        case .fireRed: return "z_fireRed"
        case .leafGreen: return "z_leafGreen"
        case .diamond: return "z_diamond"
        case .pearl: return "z_pearl"
        case .platinum: return "z_platinum"
        case .heartGold: return "z_heartGold"
        case .soulSilver: return "z_soulSilver"
        case .black: return "z_black"
        case .white: return "z_white"
        case .black2: return "z_black2"
        case .white2: return "z_white2"
        case .x: return "z_x"
        case .y: return "z_y"
        case .omegaRuby: return "z_omegaRuby"
        case .alphaSapphire: return "z_alphaSapphire"
        case .sun: return "z_sun"
        case .moon: return "z_moon"
        case .ultraSun: return "z_ultraSun"
        case .ultraMoon: return "z_ultraMoon"
        case .letsGoPikachu: return "z_letsGoPikachu"
        case .letsGoEevee: return "z_letsGoEevee"
        case .sword: return "z_sword"
        case .shield: return "z_shield"
        case .brilliantDiamond: return "z_brilliantDiamond"
        case .shiningPearl: return "z_shiningPearl"
        case .legendsArceus: return "z_legendsArceus"
        case .scarlet: return "z_scarlet"
        case .violet: return "z_violet"
        case .national: return "z_national"
        }
    }

}
