//
//  Game+Metadata.swift
//
//
//  Released-game metadata and dataset presentation policy.
//

import Foundation

extension Game {

    /// Release-only facts for a real game.
    public struct Metadata: Hashable {
        public let game: Game
        public let title: String
        public let generation: Generation

        /// Ordinal release recency. Games released as a pair share a group.
        public let releaseGroup: Int

        /// Stable selector priority. Lower values appear first.
        public let selectorOrder: Int

        public let mechanics: Mechanics
    }

    /// Mechanics belonging to a released game.
    ///
    /// Dataset visibility is modeled separately by ``DatasetFeatures``.
    public struct Mechanics: Hashable {
        public let hasBreeding: Bool
        public let hasTutoring: Bool
        public let hasTransfer: Bool
        public let hasAbilities: Bool
        public let hasTMs: Bool
        public let hasHMs: Bool
        public let hasTRs: Bool

        public var hasMachines: Bool { hasTMs || hasHMs || hasTRs }
    }

    /// Sections backed by authoritative rows for a database dataset.
    ///
    /// These flags are independent product policy. In particular, National's
    /// flags expose aggregate rows and do not describe game mechanics.
    public struct DatasetFeatures: Hashable {
        public let showsBreedingLearnsets: Bool
        public let showsTutoringLearnsets: Bool
        public let showsAbilities: Bool
        public let showsTMs: Bool
        public let showsHMs: Bool
        public let showsTRs: Bool

        public var showsMachines: Bool { showsTMs || showsHMs || showsTRs }
    }

    /// Every generated database dataset in stable identity order.
    public static let allDatasets = Game.allCases.sorted {
        $0.databaseIndex < $1.databaseIndex
    }

    /// The authoritative released-game metadata catalog.
    public static let releasedGameMetadata: [Metadata] = [
        .init(game: .scarlet, title: "Scarlet", generation: .ix, releaseGroup: 20, selectorOrder: 0, mechanics: .modern),
        .init(game: .violet, title: "Violet", generation: .ix, releaseGroup: 20, selectorOrder: 1, mechanics: .modern),
        .init(game: .legendsArceus, title: "Legends: Arceus", generation: .viii, releaseGroup: 19, selectorOrder: 2, mechanics: .legendsArceus),
        .init(game: .brilliantDiamond, title: "Brilliant Diamond", generation: .viii, releaseGroup: 18, selectorOrder: 3, mechanics: .modern),
        .init(game: .shiningPearl, title: "Shining Pearl", generation: .viii, releaseGroup: 18, selectorOrder: 4, mechanics: .modern),
        .init(game: .sword, title: "Sword", generation: .viii, releaseGroup: 17, selectorOrder: 5, mechanics: .swordAndShield),
        .init(game: .shield, title: "Shield", generation: .viii, releaseGroup: 17, selectorOrder: 6, mechanics: .swordAndShield),
        .init(game: .letsGoPikachu, title: "Let's Go, Pikachu!", generation: .vii, releaseGroup: 16, selectorOrder: 7, mechanics: .letsGo),
        .init(game: .letsGoEevee, title: "Let's Go, Eevee!", generation: .vii, releaseGroup: 16, selectorOrder: 8, mechanics: .letsGo),
        .init(game: .ultraSun, title: "Ultra Sun", generation: .vii, releaseGroup: 15, selectorOrder: 9, mechanics: .modern),
        .init(game: .ultraMoon, title: "Ultra Moon", generation: .vii, releaseGroup: 15, selectorOrder: 10, mechanics: .modern),
        .init(game: .sun, title: "Sun", generation: .vii, releaseGroup: 14, selectorOrder: 11, mechanics: .modern),
        .init(game: .moon, title: "Moon", generation: .vii, releaseGroup: 14, selectorOrder: 12, mechanics: .modern),
        .init(game: .omegaRuby, title: "Omega Ruby", generation: .vi, releaseGroup: 13, selectorOrder: 13, mechanics: .generationIIIThroughVI),
        .init(game: .alphaSapphire, title: "Alpha Sapphire", generation: .vi, releaseGroup: 13, selectorOrder: 14, mechanics: .generationIIIThroughVI),
        .init(game: .x, title: "X", generation: .vi, releaseGroup: 12, selectorOrder: 15, mechanics: .generationIIIThroughVI),
        .init(game: .y, title: "Y", generation: .vi, releaseGroup: 12, selectorOrder: 16, mechanics: .generationIIIThroughVI),
        .init(game: .black2, title: "Black 2", generation: .v, releaseGroup: 11, selectorOrder: 17, mechanics: .generationIIIThroughVI),
        .init(game: .white2, title: "White 2", generation: .v, releaseGroup: 11, selectorOrder: 18, mechanics: .generationIIIThroughVI),
        .init(game: .black, title: "Black", generation: .v, releaseGroup: 10, selectorOrder: 19, mechanics: .generationIIIThroughVI),
        .init(game: .white, title: "White", generation: .v, releaseGroup: 10, selectorOrder: 20, mechanics: .generationIIIThroughVI),
        .init(game: .heartGold, title: "HeartGold", generation: .iv, releaseGroup: 9, selectorOrder: 21, mechanics: .generationIIIThroughVI),
        .init(game: .soulSilver, title: "SoulSilver", generation: .iv, releaseGroup: 9, selectorOrder: 22, mechanics: .generationIIIThroughVI),
        .init(game: .diamond, title: "Diamond", generation: .iv, releaseGroup: 7, selectorOrder: 23, mechanics: .generationIIIThroughVI),
        .init(game: .pearl, title: "Pearl", generation: .iv, releaseGroup: 7, selectorOrder: 24, mechanics: .generationIIIThroughVI),
        .init(game: .platinum, title: "Platinum", generation: .iv, releaseGroup: 8, selectorOrder: 25, mechanics: .generationIIIThroughVI),
        .init(game: .fireRed, title: "FireRed", generation: .iii, releaseGroup: 5, selectorOrder: 26, mechanics: .generationIIIThroughVI),
        .init(game: .leafGreen, title: "LeafGreen", generation: .iii, releaseGroup: 5, selectorOrder: 27, mechanics: .generationIIIThroughVI),
        .init(game: .ruby, title: "Ruby", generation: .iii, releaseGroup: 4, selectorOrder: 28, mechanics: .generationIIIThroughVI),
        .init(game: .sapphire, title: "Sapphire", generation: .iii, releaseGroup: 4, selectorOrder: 29, mechanics: .generationIIIThroughVI),
        .init(game: .emerald, title: "Emerald", generation: .iii, releaseGroup: 6, selectorOrder: 30, mechanics: .generationIIIThroughVI),
        .init(game: .gold, title: "Gold", generation: .ii, releaseGroup: 2, selectorOrder: 31, mechanics: .generationII),
        .init(game: .silver, title: "Silver", generation: .ii, releaseGroup: 2, selectorOrder: 32, mechanics: .generationII),
        .init(game: .crystal, title: "Crystal", generation: .ii, releaseGroup: 3, selectorOrder: 33, mechanics: .generationII),
        .init(game: .red, title: "Red", generation: .i, releaseGroup: 0, selectorOrder: 34, mechanics: .generationI),
        .init(game: .blue, title: "Blue", generation: .i, releaseGroup: 0, selectorOrder: 35, mechanics: .generationI),
        .init(game: .yellow, title: "Yellow", generation: .i, releaseGroup: 1, selectorOrder: 36, mechanics: .generationI)
    ]

    /// Released games in the existing selector display order.
    ///
    /// This is not database order and is not a strict release-date sort within
    /// a generation. Use metadata release groups for release recency.
    public static var releasedGames: [Game] {
        releasedGameMetadata
            .sorted { $0.selectorOrder < $1.selectorOrder }
            .map(\.game)
    }

    /// Selector options in the existing National-first display order.
    public static var selectableGames: [Game] { [.national] + releasedGames }

    /// All games in the newest release group.
    public static var latestReleasedGames: [Game] {
        guard let latestGroup = releasedGameMetadata.map(\.releaseGroup).max() else {
            return []
        }
        return releasedGameMetadata
            .filter { $0.releaseGroup == latestGroup }
            .sorted { $0.selectorOrder < $1.selectorOrder }
            .map(\.game)
    }

    /// Product default selection, independent of release recency.
    public static let defaultReleasedGame: Game = .scarlet

    /// Metadata for a released game, or `nil` for National.
    public var metadata: Metadata? { Self.metadataByGame[self] }

    public var isReleasedGame: Bool { metadata != nil }
    public var isNational: Bool { self == .national }

    /// Dataset-level section availability independent of released mechanics.
    public var datasetFeatures: DatasetFeatures {
        switch self {
        case .red, .blue, .yellow:
            return .generationI
        case .gold, .silver, .crystal:
            return .generationII
        case .ruby, .sapphire, .emerald, .fireRed, .leafGreen,
             .diamond, .pearl, .platinum, .heartGold, .soulSilver,
             .black, .white, .black2, .white2,
             .x, .y, .omegaRuby, .alphaSapphire:
            return .generationIIIThroughVI
        case .sun, .moon, .ultraSun, .ultraMoon,
             .brilliantDiamond, .shiningPearl, .scarlet, .violet:
            return .modern
        case .letsGoPikachu, .letsGoEevee:
            return .letsGo
        case .sword, .shield:
            return .swordAndShield
        case .legendsArceus:
            return .legendsArceus
        case .national:
            return .national
        }
    }

    @available(*, deprecated, renamed: "selectableGames")
    public static var allGamesNewestFirst: [Game] { selectableGames }

    @available(*, deprecated, renamed: "releasedGames")
    public static var allGamesNewestFirstExceptNational: [Game] { releasedGames }

    private static let metadataByGame = Dictionary(
        uniqueKeysWithValues: releasedGameMetadata.map { ($0.game, $0) }
    )
}

/// Explicit rule-generation choices required by algorithms operating on the
/// aggregate National dataset. These policies do not affect database queries.
public enum NationalDatasetRules {

    /// National type availability and effectiveness use Generation IX rules.
    public static let typeEffectivenessGeneration = Generation.ix

    /// National team stat editing uses Generation IX rules.
    public static let teamBuildingGeneration = Generation.ix
}

extension Game {

    /// Real generation for type algorithms, with an explicit National policy.
    public var typeEffectivenessRulesGeneration: Generation {
        if isNational {
            return NationalDatasetRules.typeEffectivenessGeneration
        }
        guard let metadata else {
            preconditionFailure("Released game \(rawValue) is missing metadata")
        }
        return metadata.generation
    }

    /// Real generation for team-building algorithms, with an explicit National policy.
    public var teamBuildingRulesGeneration: Generation {
        if isNational {
            return NationalDatasetRules.teamBuildingGeneration
        }
        guard let metadata else {
            preconditionFailure("Released game \(rawValue) is missing metadata")
        }
        return metadata.generation
    }
}

private extension Game.Mechanics {

    static let generationI = Self(hasBreeding: false, hasTutoring: false, hasTransfer: false, hasAbilities: false, hasTMs: true, hasHMs: true, hasTRs: false)
    static let generationII = Self(hasBreeding: true, hasTutoring: true, hasTransfer: true, hasAbilities: false, hasTMs: true, hasHMs: true, hasTRs: false)
    static let generationIIIThroughVI = Self(hasBreeding: true, hasTutoring: true, hasTransfer: true, hasAbilities: true, hasTMs: true, hasHMs: true, hasTRs: false)
    static let modern = Self(hasBreeding: true, hasTutoring: true, hasTransfer: true, hasAbilities: true, hasTMs: true, hasHMs: false, hasTRs: false)
    static let letsGo = Self(hasBreeding: true, hasTutoring: true, hasTransfer: true, hasAbilities: false, hasTMs: true, hasHMs: false, hasTRs: false)
    static let swordAndShield = Self(hasBreeding: true, hasTutoring: true, hasTransfer: true, hasAbilities: true, hasTMs: true, hasHMs: false, hasTRs: true)
    static let legendsArceus = Self(hasBreeding: false, hasTutoring: true, hasTransfer: true, hasAbilities: false, hasTMs: false, hasHMs: false, hasTRs: false)
}

private extension Game.DatasetFeatures {

    static let generationI = Self(showsBreedingLearnsets: false, showsTutoringLearnsets: false, showsAbilities: false, showsTMs: true, showsHMs: true, showsTRs: false)
    static let generationII = Self(showsBreedingLearnsets: true, showsTutoringLearnsets: true, showsAbilities: false, showsTMs: true, showsHMs: true, showsTRs: false)
    static let generationIIIThroughVI = Self(showsBreedingLearnsets: true, showsTutoringLearnsets: true, showsAbilities: true, showsTMs: true, showsHMs: true, showsTRs: false)
    static let modern = Self(showsBreedingLearnsets: true, showsTutoringLearnsets: true, showsAbilities: true, showsTMs: true, showsHMs: false, showsTRs: false)
    static let letsGo = Self(showsBreedingLearnsets: true, showsTutoringLearnsets: true, showsAbilities: false, showsTMs: true, showsHMs: false, showsTRs: false)
    static let swordAndShield = Self(showsBreedingLearnsets: true, showsTutoringLearnsets: true, showsAbilities: true, showsTMs: true, showsHMs: false, showsTRs: true)
    static let legendsArceus = Self(showsBreedingLearnsets: false, showsTutoringLearnsets: true, showsAbilities: false, showsTMs: false, showsHMs: false, showsTRs: false)
    static let national = Self(showsBreedingLearnsets: true, showsTutoringLearnsets: true, showsAbilities: true, showsTMs: true, showsHMs: false, showsTRs: true)
}
