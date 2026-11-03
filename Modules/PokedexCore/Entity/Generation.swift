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
    case ix
    case all = 1000

    /// Creates a released generation for a real game.
    ///
    /// Returns `nil` for National because National is a database dataset, not a
    /// released game.
    public init?(game: Game) {
        guard let generation = game.metadata?.generation else {
            return nil
        }
        self = generation
    }
}

extension Generation {

    public static var latest: Generation {
        guard let latest = Game.releasedGameMetadata.map(\.generation).max() else {
            preconditionFailure("Released-game metadata catalog must not be empty")
        }
        return latest
    }

    public static var releasedCases: [Generation] {
        allCases.filter { $0 != .all }
    }

    public static var releasedCasesLatestFirst: [Generation] {
        Array(releasedCases.reversed())
    }

    @available(*, deprecated, renamed: "releasedCases")
    public static var allCasesWithoutAll: [Generation] { releasedCases }

    @available(*, deprecated, renamed: "releasedCasesLatestFirst")
    public static var allCasesLatestFirst: [Generation] { releasedCasesLatestFirst }

    public var title: String {
        self == .all ? "All Generations" : "Generation \(rawValue)"
    }

    public var shortTitle: String {
        self == .all ? "All" : "Gen. \(rawValue)"
    }

    /// Released games in the generation, in the selector's existing order.
    public var games: [Game] {
        guard self != .all else { return [] }
        return Game.releasedGameMetadata
            .filter { $0.generation == self }
            .map(\.game)
            .sorted { $0.databaseIndex < $1.databaseIndex }
    }

    /// Explicit product default for this generation, independent of recency.
    public var defaultGame: Game? {
        switch self {
        case .i: return .red
        case .ii: return .gold
        case .iii: return .ruby
        case .iv: return .diamond
        case .v: return .black
        case .vi: return .x
        case .vii: return .sun
        case .viii: return .sword
        case .ix: return .scarlet
        case .all: return nil
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
        case 9: self = .ix
        case 1000: self = .all
        default: preconditionFailure("Unsupported generation raw value: \(value)")
        }
    }
}
