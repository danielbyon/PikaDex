//
//  Ability+Extension.swift
//  Database
//
//  Created by Daniel Byon on 12/18/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Fetch Requests
public extension Ability {

    static func allFetchRequest(for game: Game) -> NSFetchRequest<Ability> {
        let request: NSFetchRequest<Ability> = Ability.fetchRequest()
        request.predicate = NSPredicate(format: "\(#keyPath(Ability.z_generationIntroduced)) <= %d", game.generation.rawValue)
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Ability.z_name), ascending: true)]
        return request
    }

    static func fetchRequest(forName name: String) -> NSFetchRequest<Ability> {
        let request: NSFetchRequest<Ability> = Ability.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "\(#keyPath(Ability.z_name)) LIKE[cd] %@", name)
        request.returnsObjectsAsFaults = false
        return request
    }

}

// MARK: - CanonicallyNamed
extension Ability: CanonicallyNamed {

    var canonicalName: String { z_canonicalName ?? _missingString }

}

//// MARK: - Identifiable
//extension Ability: Identifiable {
//
//    public var id: String { name }
//
//}

// MARK: - Properties
public extension Ability {

    subscript(game: Game) -> String? {
        get { description(forGame: game) }
        set { setDescription(newValue, forGame: game) }
    }

    private var fallbackDescriptionLatestFirst: String? {
        // If this fails, something is wrong in the data pipeline. We should not
        // have an Ability without at least one description.
        Game.allGamesNewestFirst
            .lazy
            .compactMap { self.description(forGame: $0) }
            .first
    }

    func resolvedDescription(forGame game: Game) -> String? {
        guard game.generation >= generationIntroduced else {
            return fallbackDescriptionLatestFirst
        }
        return description(forGame: game)
    }

}

// MARK: - Values
public extension Ability {

    var generationIntroduced: Generation {
        get { Generation(rawValue: Int(z_generationIntroduced))! }
        set { z_generationIntroduced = Int64(newValue.rawValue) }
    }
    var index: Int {
        get { Int(z_index) }
        set { z_index = Int64(newValue) }
    }
    var name: String {
        get { z_name! }
        set { z_name = newValue; z_canonicalName = newValue.normalizedForSearch }
    }

    func description(forGame game: Game) -> String? {
        guard game.generation.hasAbilities else { return nil }
        return value(forKeyPath: descriptionKeyPath(forGame: game)) as? String
    }

    func setDescription(_ description: String?, forGame game: Game) {
        guard game.generation.hasAbilities else { return }
        setValue(description, forKeyPath: descriptionKeyPath(forGame: game))
    }

}

// MARK: - Database Support
private extension Ability {

    func descriptionKeyPath(forGame game: Game) -> String {
        switch game {
        case .red,
             .blue,
             .yellow,
             .gold,
             .silver,
             .crystal:
            assertionFailure()
            return descriptionKeyPath(forGame: Generation.latest.defaultGame)
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
        case .national: return "z_national"
        }
    }

}
