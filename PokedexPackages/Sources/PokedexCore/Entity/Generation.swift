//
//  Generation.swift
//
//
//  Created by Daniel Byon on 7/18/16.
//

import Foundation

public enum Generation: Int, CaseIterable {

    case i = 1
    case ii
    case iii
    case iv
    case v
    case vi
    case vii
    case viii
    case all = 1000

    public init(game: Game) {
        switch game {
        case .red, .blue, .yellow:
            self = .i
        case .gold, .silver, .crystal:
            self = .ii
        case .ruby, .sapphire, .emerald, .fireRed, .leafGreen:
            self = .iii
        case .diamond, .pearl, .platinum, .heartGold, .soulSilver:
            self = .iv
        case .black, .white, .black2, .white2:
            self = .v
        case .x, .y, .omegaRuby, .alphaSapphire:
            self = .vi
        case .sun, .moon, .ultraSun, .ultraMoon, .letsGoPikachu, .letsGoEevee:
            self = .vii
        case .sword, .shield, .brilliantDiamond, .shiningPearl, .legendsArceus:
            self = .viii
        case .national:
            self = .all
        }
    }

}

extension Generation {

    public static var latest: Generation { Generation.allCases.filter { $0 != .all }.last! }

    public var title: String {
        if self == .all {
            return "National"
        } else {
            return "Generation \(rawValue)"
        }
    }

    public var shortTitle: String {
        if self == .all {
            return "Ntnl"
        } else {
            return "Gen. \(rawValue)"
        }
    }

    public var games: [Game] {
        switch self {
        case .i:
            return [.red, .blue, .yellow]
        case .ii:
            return [.gold, .silver, .crystal]
        case .iii:
            return [.ruby, .sapphire, .emerald, .fireRed, .leafGreen]
        case .iv:
            return [.diamond, .pearl, .platinum, .heartGold, .soulSilver]
        case .v:
            return [.black, .white, .black2, .white2]
        case .vi:
            return [.x, .y, .omegaRuby, .alphaSapphire]
        case .vii:
            return [.sun, .moon, .ultraSun, .ultraMoon, .letsGoPikachu, .letsGoEevee]
        case .viii:
            return [.sword, .shield, .brilliantDiamond, .shiningPearl, .legendsArceus]
        case .all:
            return [.national]
        }
    }

    public var defaultGame: Game {
        switch self {
        case .i:
            return .red
        case .ii:
            return .gold
        case .iii:
            return .ruby
        case .iv:
            return .diamond
        case .v:
            return .black
        case .vi:
            return .x
        case .vii:
            return .sun
        case .viii:
            return .sword
        case .all:
            return .national
        }
    }

    public var hasAbilities: Bool { self >= .iii }

}

extension Generation: Codable { }

extension Generation: Comparable {
    
    public static func < (lhs: Generation, rhs: Generation) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
}

extension Generation: Hashable { }

extension Generation: Identifiable {
    
    public var id: Int { rawValue }
    
}

extension Generation: ExpressibleByIntegerLiteral {

    public typealias IntegerLiteralType = RawValue

    public init(integerLiteral value: Int) {
        switch value {
        case 1: self = .i
        case 2: self = .ii
        case 3: self = .iii
        case 4: self = .iv
        case 5: self = .v
        case 6: self = .vi
        case 7: self = .vii
        case 8: self = .viii
        case 1000: self = .all
        default:
            fatalError()
        }
    }

}
