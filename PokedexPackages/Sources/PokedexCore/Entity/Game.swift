//
//  Game.swift
//
//
//  Created by Daniel Byon on 7/18/16.
//

import Foundation

public enum Game: String, CaseIterable {

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
    case brilliantDiamond
    case shiningPearl
    case legendsArceus
    case scarlet
    case violet

    /// Technically not a game
    case national

}

extension Game {

    public static var allGamesNewestFirstExceptNational: [Game] { allGamesNewestFirst.filter { $0 != .national } }

    public static let allGamesNewestFirst: [Game] = [
        .national,
        .scarlet,
        .violet,
        .legendsArceus,
        .brilliantDiamond,
        .shiningPearl,
        .sword,
        .shield,
        .letsGoPikachu,
        .letsGoEevee,
        .ultraSun,
        .ultraMoon,
        .sun,
        .moon,
        .omegaRuby,
        .alphaSapphire,
        .x,
        .y,
        .black2,
        .white2,
        .black,
        .white,
        .heartGold,
        .soulSilver,
        .diamond,
        .pearl,
        .platinum,
        .fireRed,
        .leafGreen,
        .ruby,
        .sapphire,
        .emerald,
        .gold,
        .silver,
        .crystal,
        .red,
        .blue,
        .yellow
    ]

    public var generation: Generation {
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
        case .sword, .shield, .brilliantDiamond, .shiningPearl, .legendsArceus:
            return .viii
        case .scarlet, .violet:
            return .ix
        case .national:
            return .all
        }
    }

    public var key: String { rawValue }
    
    public var title: String {
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
        case .brilliantDiamond: return "Brilliant Diamond"
        case .shiningPearl: return "Shining Pearl"
        case .legendsArceus: return "Legends: Arceus"
        case .scarlet: return "Scarlet"
        case .violet: return "Violet"
        case .national: return "National"
        }
    }

    public var index: Int { Self.allCases.firstIndex(of: self)! }

    public var hasBreeding: Bool { generation >= .ii && self != .legendsArceus }

    public var hasTutoring: Bool { generation >= .ii }

    public var hasTransfer: Bool { generation >= .ii }

    public var hasAbilities: Bool {
        generation >= .iii
        && self != .letsGoPikachu
        && self != .letsGoEevee
        && self != .legendsArceus
    }

    public var hasTMs: Bool { self != .legendsArceus }

    public var hasHMs: Bool { generation < 7 && self != .legendsArceus }

    public var hasTRs: Bool { self == .sword || self == .shield || self == .national }
    
    public var hasMachines: Bool { hasTMs || hasHMs || hasTRs }

}

extension Game: Codable { }

extension Game: Comparable {
    
    public static func < (lhs: Game, rhs: Game) -> Bool {
        Game.allCases.firstIndex(of: lhs) ?? 0 < Game.allCases.firstIndex(of: rhs) ?? 0
    }
    
}

extension Game: Hashable { }

extension Game: Identifiable {
    
    public var id: String { rawValue }
    
}

extension Notification.Name {

    public static let currentGameChanged = Notification.Name("com.danielbyon.pokedex.currentGameChanged")

}
