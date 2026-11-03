//
//  GameTests.swift
//
//
//  Created by Daniel Byon on 9/19/22.
//

import SwiftUI
import XCTest

@testable import PokedexCore

final class GameTests: XCTestCase {

    func testStableDatasetIdentity() {
        XCTAssertEqual(Game.allDatasets.count, expectedDatasets.count)

        for (expectedIndex, expected) in expectedDatasets.enumerated() {
            XCTAssertEqual(expected.game.rawValue, expected.rawValue)
            XCTAssertEqual(expected.game.databaseIndex, expectedIndex)
            XCTAssertEqual(expected.game.index, expectedIndex)
        }

        XCTAssertEqual(Game.allDatasets.sorted(), Game.allDatasets)
    }

    func testReleasedMetadataCompletenessAndOrdering() {
        let metadata = Game.releasedGameMetadata

        XCTAssertEqual(metadata.count, Game.allDatasets.count - 1)
        XCTAssertEqual(Set(metadata.map(\.game)).count, metadata.count)
        XCTAssertEqual(Set(metadata.map(\.selectorOrder)), Set(0..<metadata.count))
        XCTAssertEqual(Game.releasedGames, Array(expectedSelectorOrder.dropFirst()))
        XCTAssertEqual(Game.selectableGames, expectedSelectorOrder)
        XCTAssertEqual(Game.allGamesNewestFirst, expectedSelectorOrder)
        XCTAssertEqual(Game.allGamesNewestFirstExceptNational, Array(expectedSelectorOrder.dropFirst()))

        for game in Game.releasedGames {
            XCTAssertNotNil(game.metadata)
            XCTAssertTrue(game.isReleasedGame)
            XCTAssertFalse(game.isNational)
            XCTAssertEqual(game.title, expectedDatasets[game.databaseIndex].title)
            XCTAssertEqual(game.metadata?.releaseGroup, expectedReleaseGroup(for: game), "\(game)")
        }

        XCTAssertNil(Game.national.metadata)
        XCTAssertFalse(Game.national.isReleasedGame)
        XCTAssertTrue(Game.national.isNational)
        XCTAssertEqual(Game.national.title, "National")
    }

    func testReleaseRecencyAndProductDefaultAreIndependent() {
        XCTAssertEqual(Game.latestReleasedGames, [.scarlet, .violet])
        XCTAssertEqual(
            Game.scarlet.metadata?.releaseGroup,
            Game.violet.metadata?.releaseGroup
        )
        XCTAssertEqual(Game.defaultReleasedGame, .scarlet)
        XCTAssertEqual(Generation.ix.defaultGame, .scarlet)
    }

    func testGenerationMembershipDerivesFromMetadata() {
        let expected: [(Generation, [Game], Game?)] = [
            (.i, [.red, .blue, .yellow], .red),
            (.ii, [.gold, .silver, .crystal], .gold),
            (.iii, [.ruby, .sapphire, .emerald, .fireRed, .leafGreen], .ruby),
            (.iv, [.diamond, .pearl, .platinum, .heartGold, .soulSilver], .diamond),
            (.v, [.black, .white, .black2, .white2], .black),
            (.vi, [.x, .y, .omegaRuby, .alphaSapphire], .x),
            (.vii, [.sun, .moon, .ultraSun, .ultraMoon, .letsGoPikachu, .letsGoEevee], .sun),
            (.viii, [.sword, .shield, .brilliantDiamond, .shiningPearl, .legendsArceus], .sword),
            (.ix, [.scarlet, .violet], .scarlet),
            (.all, [], nil)
        ]

        for (generation, games, defaultGame) in expected {
            XCTAssertEqual(generation.games, games)
            XCTAssertEqual(generation.defaultGame, defaultGame)
            games.forEach {
                XCTAssertEqual($0.metadata?.generation, generation)
                XCTAssertEqual(Generation(game: $0), generation)
            }
        }

        XCTAssertNil(Generation(game: .national))
        XCTAssertNil(Game.national.generation)
        XCTAssertEqual(Generation.latest, .ix)
        XCTAssertEqual(Generation.releasedCasesLatestFirst, [.ix, .viii, .vii, .vi, .v, .iv, .iii, .ii, .i])
        XCTAssertEqual(Generation.all.title, "All Generations")
        XCTAssertEqual(Generation.all.shortTitle, "All")
    }

    func testReleasedMechanicsParity() {
        for game in Game.releasedGames {
            guard let mechanics = game.metadata?.mechanics else {
                return XCTFail("Missing mechanics for \(game)")
            }
            let expected = expectedMechanics(for: game)
            XCTAssertEqual(mechanics.hasBreeding, expected.hasBreeding, "\(game)")
            XCTAssertEqual(mechanics.hasTutoring, expected.hasTutoring, "\(game)")
            XCTAssertEqual(mechanics.hasTransfer, expected.hasTransfer, "\(game)")
            XCTAssertEqual(mechanics.hasAbilities, expected.hasAbilities, "\(game)")
            XCTAssertEqual(mechanics.hasTMs, expected.hasTMs, "\(game)")
            XCTAssertEqual(mechanics.hasHMs, expected.hasHMs, "\(game)")
            XCTAssertEqual(mechanics.hasTRs, expected.hasTRs, "\(game)")
            XCTAssertEqual(mechanics.hasMachines, expected.hasMachines, "\(game)")

            XCTAssertEqual(game.hasBreeding, expected.hasBreeding, "\(game)")
            XCTAssertEqual(game.hasTutoring, expected.hasTutoring, "\(game)")
            XCTAssertEqual(game.hasTransfer, expected.hasTransfer, "\(game)")
            XCTAssertEqual(game.hasAbilities, expected.hasAbilities, "\(game)")
            XCTAssertEqual(game.hasTMs, expected.hasTMs, "\(game)")
            XCTAssertEqual(game.hasHMs, expected.hasHMs, "\(game)")
            XCTAssertEqual(game.hasTRs, expected.hasTRs, "\(game)")
            XCTAssertEqual(game.hasMachines, expected.hasMachines, "\(game)")
        }

        XCTAssertFalse(Game.national.hasBreeding)
        XCTAssertFalse(Game.national.hasTutoring)
        XCTAssertFalse(Game.national.hasTransfer)
        XCTAssertFalse(Game.national.hasAbilities)
        XCTAssertFalse(Game.national.hasTMs)
        XCTAssertFalse(Game.national.hasHMs)
        XCTAssertFalse(Game.national.hasTRs)
        XCTAssertFalse(Game.national.hasMachines)
    }

    func testDatasetFeaturesAreIndependentPolicy() {
        for game in Game.allDatasets {
            XCTAssertEqual(game.datasetFeatures, expectedDatasetFeatures(for: game), "\(game)")
        }

        XCTAssertTrue(Game.national.datasetFeatures.showsAbilities)
        XCTAssertTrue(Game.national.datasetFeatures.showsBreedingLearnsets)
        XCTAssertTrue(Game.national.datasetFeatures.showsTutoringLearnsets)
        XCTAssertTrue(Game.national.datasetFeatures.showsTMs)
        XCTAssertFalse(Game.national.datasetFeatures.showsHMs)
        XCTAssertTrue(Game.national.datasetFeatures.showsTRs)
        XCTAssertTrue(Game.national.datasetFeatures.showsMachines)
        XCTAssertFalse(Game.national.hasMachines)
    }

    func testNationalRulesPoliciesAreNarrowAndExplicit() {
        XCTAssertEqual(NationalDatasetRules.typeEffectivenessGeneration, .ix)
        XCTAssertEqual(NationalDatasetRules.teamBuildingGeneration, .ix)
        XCTAssertEqual(Game.national.typeEffectivenessRulesGeneration, .ix)
        XCTAssertEqual(Game.national.teamBuildingRulesGeneration, .ix)

        for game in Game.releasedGames {
            XCTAssertEqual(game.typeEffectivenessRulesGeneration, game.metadata?.generation)
            XCTAssertEqual(game.teamBuildingRulesGeneration, game.metadata?.generation)
        }
    }

    func testNationalPersistenceCompatibility() throws {
        XCTAssertEqual(Game(rawValue: "national"), .national)
        XCTAssertEqual(try JSONDecoder().decode(Game.self, from: Data("\"national\"".utf8)), .national)
        XCTAssertEqual(String(data: try JSONEncoder().encode(Game.national), encoding: .utf8), "\"national\"")

        let suiteName = "GameTests-\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        defaults.set(Game.national.rawValue, forKey: AppSetting<Game>.currentGame.key)
        var fixture = GameAppStorageFixture(defaults: defaults)
        XCTAssertEqual(fixture.currentGame, .national)

        fixture.currentGame = .violet
        XCTAssertEqual(defaults.string(forKey: AppSetting<Game>.currentGame.key), Game.violet.rawValue)

        let team = Team(name: "National Team", internalID: UUID(uuidString: "731E690B-8C1D-4E29-B0F1-2E8A90448C0E")!)
        defaults.saveTeams([team], forGame: .national)
        XCTAssertEqual(defaults.loadTeams(forGame: .national), [team])
    }
}

private struct GameAppStorageFixture {

    @AppStorage var currentGame: Game

    init(defaults: UserDefaults) {
        _currentGame = AppStorage(
            wrappedValue: .sword,
            AppSetting<Game>.currentGame.key,
            store: defaults
        )
    }
}

private struct ExpectedMechanics {
    let hasBreeding: Bool
    let hasTutoring: Bool
    let hasTransfer: Bool
    let hasAbilities: Bool
    let hasTMs: Bool
    let hasHMs: Bool
    let hasTRs: Bool
    var hasMachines: Bool { hasTMs || hasHMs || hasTRs }
}

private func expectedMechanics(for game: Game) -> ExpectedMechanics {
    switch game {
    case .red, .blue, .yellow:
        return .init(hasBreeding: false, hasTutoring: false, hasTransfer: false, hasAbilities: false, hasTMs: true, hasHMs: true, hasTRs: false)
    case .gold, .silver, .crystal:
        return .init(hasBreeding: true, hasTutoring: true, hasTransfer: true, hasAbilities: false, hasTMs: true, hasHMs: true, hasTRs: false)
    case .ruby, .sapphire, .emerald, .fireRed, .leafGreen,
         .diamond, .pearl, .platinum, .heartGold, .soulSilver,
         .black, .white, .black2, .white2,
         .x, .y, .omegaRuby, .alphaSapphire:
        return .init(hasBreeding: true, hasTutoring: true, hasTransfer: true, hasAbilities: true, hasTMs: true, hasHMs: true, hasTRs: false)
    case .sun, .moon, .ultraSun, .ultraMoon,
         .brilliantDiamond, .shiningPearl, .scarlet, .violet:
        return .init(hasBreeding: true, hasTutoring: true, hasTransfer: true, hasAbilities: true, hasTMs: true, hasHMs: false, hasTRs: false)
    case .letsGoPikachu, .letsGoEevee:
        return .init(hasBreeding: true, hasTutoring: true, hasTransfer: true, hasAbilities: false, hasTMs: true, hasHMs: false, hasTRs: false)
    case .sword, .shield:
        return .init(hasBreeding: true, hasTutoring: true, hasTransfer: true, hasAbilities: true, hasTMs: true, hasHMs: false, hasTRs: true)
    case .legendsArceus:
        return .init(hasBreeding: false, hasTutoring: true, hasTransfer: true, hasAbilities: false, hasTMs: false, hasHMs: false, hasTRs: false)
    case .national:
        preconditionFailure("National has no released-game mechanics")
    }
}

private func expectedReleaseGroup(for game: Game) -> Int {
    switch game {
    case .red, .blue: return 0
    case .yellow: return 1
    case .gold, .silver: return 2
    case .crystal: return 3
    case .ruby, .sapphire: return 4
    case .fireRed, .leafGreen: return 5
    case .emerald: return 6
    case .diamond, .pearl: return 7
    case .platinum: return 8
    case .heartGold, .soulSilver: return 9
    case .black, .white: return 10
    case .black2, .white2: return 11
    case .x, .y: return 12
    case .omegaRuby, .alphaSapphire: return 13
    case .sun, .moon: return 14
    case .ultraSun, .ultraMoon: return 15
    case .letsGoPikachu, .letsGoEevee: return 16
    case .sword, .shield: return 17
    case .brilliantDiamond, .shiningPearl: return 18
    case .legendsArceus: return 19
    case .scarlet, .violet: return 20
    case .national:
        preconditionFailure("National has no release group")
    }
}

private func expectedDatasetFeatures(for game: Game) -> Game.DatasetFeatures {
    switch game {
    case .red, .blue, .yellow:
        return .init(showsBreedingLearnsets: false, showsTutoringLearnsets: false, showsAbilities: false, showsTMs: true, showsHMs: true, showsTRs: false)
    case .gold, .silver, .crystal:
        return .init(showsBreedingLearnsets: true, showsTutoringLearnsets: true, showsAbilities: false, showsTMs: true, showsHMs: true, showsTRs: false)
    case .ruby, .sapphire, .emerald, .fireRed, .leafGreen,
         .diamond, .pearl, .platinum, .heartGold, .soulSilver,
         .black, .white, .black2, .white2,
         .x, .y, .omegaRuby, .alphaSapphire:
        return .init(showsBreedingLearnsets: true, showsTutoringLearnsets: true, showsAbilities: true, showsTMs: true, showsHMs: true, showsTRs: false)
    case .sun, .moon, .ultraSun, .ultraMoon,
         .brilliantDiamond, .shiningPearl, .scarlet, .violet:
        return .init(showsBreedingLearnsets: true, showsTutoringLearnsets: true, showsAbilities: true, showsTMs: true, showsHMs: false, showsTRs: false)
    case .letsGoPikachu, .letsGoEevee:
        return .init(showsBreedingLearnsets: true, showsTutoringLearnsets: true, showsAbilities: false, showsTMs: true, showsHMs: false, showsTRs: false)
    case .sword, .shield:
        return .init(showsBreedingLearnsets: true, showsTutoringLearnsets: true, showsAbilities: true, showsTMs: true, showsHMs: false, showsTRs: true)
    case .legendsArceus:
        return .init(showsBreedingLearnsets: false, showsTutoringLearnsets: true, showsAbilities: false, showsTMs: false, showsHMs: false, showsTRs: false)
    case .national:
        return .init(showsBreedingLearnsets: true, showsTutoringLearnsets: true, showsAbilities: true, showsTMs: true, showsHMs: false, showsTRs: true)
    }
}

private let expectedDatasets: [(game: Game, rawValue: String, title: String)] = [
    (.red, "red", "Red"),
    (.blue, "blue", "Blue"),
    (.yellow, "yellow", "Yellow"),
    (.gold, "gold", "Gold"),
    (.silver, "silver", "Silver"),
    (.crystal, "crystal", "Crystal"),
    (.ruby, "ruby", "Ruby"),
    (.sapphire, "sapphire", "Sapphire"),
    (.emerald, "emerald", "Emerald"),
    (.fireRed, "fireRed", "FireRed"),
    (.leafGreen, "leafGreen", "LeafGreen"),
    (.diamond, "diamond", "Diamond"),
    (.pearl, "pearl", "Pearl"),
    (.platinum, "platinum", "Platinum"),
    (.heartGold, "heartGold", "HeartGold"),
    (.soulSilver, "soulSilver", "SoulSilver"),
    (.black, "black", "Black"),
    (.white, "white", "White"),
    (.black2, "black2", "Black 2"),
    (.white2, "white2", "White 2"),
    (.x, "x", "X"),
    (.y, "y", "Y"),
    (.omegaRuby, "omegaRuby", "Omega Ruby"),
    (.alphaSapphire, "alphaSapphire", "Alpha Sapphire"),
    (.sun, "sun", "Sun"),
    (.moon, "moon", "Moon"),
    (.ultraSun, "ultraSun", "Ultra Sun"),
    (.ultraMoon, "ultraMoon", "Ultra Moon"),
    (.letsGoPikachu, "letsGoPikachu", "Let's Go, Pikachu!"),
    (.letsGoEevee, "letsGoEevee", "Let's Go, Eevee!"),
    (.sword, "sword", "Sword"),
    (.shield, "shield", "Shield"),
    (.brilliantDiamond, "brilliantDiamond", "Brilliant Diamond"),
    (.shiningPearl, "shiningPearl", "Shining Pearl"),
    (.legendsArceus, "legendsArceus", "Legends: Arceus"),
    (.scarlet, "scarlet", "Scarlet"),
    (.violet, "violet", "Violet"),
    (.national, "national", "National")
]

private let expectedSelectorOrder: [Game] = [
    .national,
    .scarlet, .violet,
    .legendsArceus,
    .brilliantDiamond, .shiningPearl,
    .sword, .shield,
    .letsGoPikachu, .letsGoEevee,
    .ultraSun, .ultraMoon,
    .sun, .moon,
    .omegaRuby, .alphaSapphire,
    .x, .y,
    .black2, .white2,
    .black, .white,
    .heartGold, .soulSilver,
    .diamond, .pearl, .platinum,
    .fireRed, .leafGreen,
    .ruby, .sapphire, .emerald,
    .gold, .silver, .crystal,
    .red, .blue, .yellow
]
