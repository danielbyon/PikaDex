//
//  Game.swift
//
//
//  Created by Daniel Byon on 7/18/16.
//

import Foundation

public enum Game: String, CaseIterable, Codable, Hashable {

    case red
    case blue
    case yellow
    case gold
    case silver
    case crystal
    case ruby
    case sapphire
    case emerald
    case fireRed
    case leafGreen
    case diamond
    case pearl
    case platinum
    case heartGold
    case soulSilver
    case black
    case white
    case black2
    case white2
    case x
    case y
    case omegaRuby
    case alphaSapphire
    case sun
    case moon
    case ultraSun
    case ultraMoon
    case letsGoPikachu
    case letsGoEevee
    case sword
    case shield

}

public extension Game {

    static let allGamesNewestFirst = [Game.sword, .shield, .letsGoPikachu, .letsGoEevee, .ultraSun, .ultraMoon, .sun, .moon, .omegaRuby, .alphaSapphire, .x, .y, .black2, .white2, .black, .white, .heartGold, .soulSilver, .diamond, .pearl, .platinum, .fireRed, .leafGreen, .ruby, .sapphire, .emerald, .gold, .silver, .crystal, .red, .blue, .yellow]

    var generation: Generation {
        switch self {
        case .red, .blue, .yellow:
            return .i
        case .gold, .silver, .crystal:
            return .ii
        case .ruby, .sapphire, .emerald, .fireRed, .leafGreen:
            return .iii
        case .diamond, .pearl, .platinum, .heartGold, .soulSilver:
            return .iv
        case .black, .white, .black2, .white2:
            return .v
        case .x, .y, .omegaRuby, .alphaSapphire:
            return .vi
        case .sun, .moon, .ultraSun, .ultraMoon, .letsGoPikachu, .letsGoEevee:
            return .vii
        case .sword, .shield:
            return .viii
        }
    }

    var key: String { rawValue }
    
    var title: String {
        switch self {
        case .red: return "Red"
        case .blue: return "Blue"
        case .yellow: return "Yellow"
        case .gold: return "Gold"
        case .silver: return "Silver"
        case .crystal: return "Crystal"
        case .ruby: return "Ruby"
        case .sapphire: return "Sapphire"
        case .emerald: return "Emerald"
        case .fireRed: return "FireRed"
        case .leafGreen: return "LeafGreen"
        case .diamond: return "Diamond"
        case .pearl: return "Pearl"
        case .platinum: return "Platinum"
        case .heartGold: return "HeartGold"
        case .soulSilver: return "SoulSilver"
        case .black: return "Black"
        case .white: return "White"
        case .black2: return "Black 2"
        case .white2: return "White 2"
        case .x: return "X"
        case .y: return "Y"
        case .omegaRuby: return "Omega Ruby"
        case .alphaSapphire: return "Alpha Sapphire"
        case .sun: return "Sun"
        case .moon: return "Moon"
        case .ultraSun: return "Ultra Sun"
        case .ultraMoon: return "Ultra Moon"
        case .letsGoPikachu: return "Let's Go, Pikachu!"
        case .letsGoEevee: return "Let's Go, Eevee!"
        case .sword: return "Sword"
        case .shield: return "Shield"
        }
    }

    var index: Int { Self.allCases.firstIndex(of: self)! }

    var hasBreeding: Bool { generation >= .ii }

    var hasTutoring: Bool { generation >= .ii }

    var hasTransfer: Bool { generation >= .ii }

    var hasAbilities: Bool { generation >= .iii && self != .letsGoPikachu && self != .letsGoEevee }

    var hasTMs: Bool { true }

    var hasHMs: Bool { generation < 7 }

    var hasTRs: Bool { generation >= 8 }

}

extension Game: Comparable {
    
    public static func < (lhs: Game, rhs: Game) -> Bool {
        Game.allCases.firstIndex(of: lhs) ?? 0 < Game.allCases.firstIndex(of: rhs) ?? 0
    }
    
}

extension Game: Identifiable {
    
    public var id: String { rawValue }
    
}

public extension Notification.Name {

    static let currentGameChanged = Notification.Name("com.danielbyon.pokedex.currentGameChanged")

}
