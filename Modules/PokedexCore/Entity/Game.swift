//
//  Game.swift
//
//
//  Created by Daniel Byon on 7/18/16.
//

import Foundation

/// A stable database dataset identifier.
///
/// Released games and the aggregate National dataset share this identifier type
/// because the generated database stores explicit rows for every value. Release
/// metadata is available separately through ``metadata``.
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

    /// The aggregate database dataset. National is not a released game.
    case national

}

extension Game {

    /// The stable integer stored in generated database rows.
    ///
    /// These values are an explicit persistence contract. They are independent
    /// of enum declaration order, selector order, and release recency.
    public var databaseIndex: Int {
        switch self {
        case .red: return 0
        case .blue: return 1
        case .yellow: return 2
        case .gold: return 3
        case .silver: return 4
        case .crystal: return 5
        case .ruby: return 6
        case .sapphire: return 7
        case .emerald: return 8
        case .fireRed: return 9
        case .leafGreen: return 10
        case .diamond: return 11
        case .pearl: return 12
        case .platinum: return 13
        case .heartGold: return 14
        case .soulSilver: return 15
        case .black: return 16
        case .white: return 17
        case .black2: return 18
        case .white2: return 19
        case .x: return 20
        case .y: return 21
        case .omegaRuby: return 22
        case .alphaSapphire: return 23
        case .sun: return 24
        case .moon: return 25
        case .ultraSun: return 26
        case .ultraMoon: return 27
        case .letsGoPikachu: return 28
        case .letsGoEevee: return 29
        case .sword: return 30
        case .shield: return 31
        case .brilliantDiamond: return 32
        case .shiningPearl: return 33
        case .legendsArceus: return 34
        case .scarlet: return 35
        case .violet: return 36
        case .national: return 37
        }
    }

    /// Compatibility alias for the stable generated-database index.
    @available(*, deprecated, renamed: "databaseIndex")
    public var index: Int { databaseIndex }

    public var key: String { rawValue }

    /// The user-facing dataset title.
    public var title: String {
        if isNational {
            return "National"
        }
        guard let metadata else {
            preconditionFailure("Released game \(rawValue) is missing metadata")
        }
        return metadata.title
    }

    /// Compatibility access to released-game generation metadata.
    ///
    /// National returns `nil` because it is an aggregate dataset rather than a
    /// released game. New code should read ``metadata`` explicitly.
    @available(*, deprecated, message: "Use metadata?.generation; National has no released-game generation")
    public var generation: Generation? { metadata?.generation }

    public var hasBreeding: Bool { metadata?.mechanics.hasBreeding ?? false }
    public var hasTutoring: Bool { metadata?.mechanics.hasTutoring ?? false }
    public var hasTransfer: Bool { metadata?.mechanics.hasTransfer ?? false }
    public var hasAbilities: Bool { metadata?.mechanics.hasAbilities ?? false }
    public var hasTMs: Bool { metadata?.mechanics.hasTMs ?? false }
    public var hasHMs: Bool { metadata?.mechanics.hasHMs ?? false }
    public var hasTRs: Bool { metadata?.mechanics.hasTRs ?? false }
    public var hasMachines: Bool { metadata?.mechanics.hasMachines ?? false }

}

extension Game: Codable { }

extension Game: Comparable {

    /// Compares stable database identity order only.
    ///
    /// Use ``releasedGames`` for selector display order and
    /// ``latestReleasedGames`` for release recency.
    public static func < (lhs: Game, rhs: Game) -> Bool {
        lhs.databaseIndex < rhs.databaseIndex
    }

}

extension Game: Hashable { }

extension Game: Identifiable {

    public var id: String { rawValue }

}

extension Notification.Name {

    public static let currentGameChanged = Notification.Name("com.danielbyon.pokedex.currentGameChanged")

}
