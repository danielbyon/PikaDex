import XCTest

@testable import PokedexCore

final class GameBitwiseValueTests: XCTestCase {

    func testReleasedGamesRetainTheirPersistedValues() {
        let expectedValues: [(Game, Int64)] = [
            (.red, 0x0000000001),
            (.blue, 0x0000000002),
            (.yellow, 0x0000000004),
            (.gold, 0x0000000008),
            (.silver, 0x0000000010),
            (.crystal, 0x0000000020),
            (.ruby, 0x0000000040),
            (.sapphire, 0x0000000080),
            (.emerald, 0x0000000100),
            (.fireRed, 0x0000000200),
            (.leafGreen, 0x0000000400),
            (.diamond, 0x0000000800),
            (.pearl, 0x0000001000),
            (.platinum, 0x0000002000),
            (.heartGold, 0x0000004000),
            (.soulSilver, 0x0000008000),
            (.black, 0x0000010000),
            (.white, 0x0000020000),
            (.black2, 0x0000040000),
            (.white2, 0x0000080000),
            (.x, 0x0000100000),
            (.y, 0x0000200000),
            (.omegaRuby, 0x0000400000),
            (.alphaSapphire, 0x0000800000),
            (.sun, 0x0001000000),
            (.moon, 0x0002000000),
            (.ultraSun, 0x0004000000),
            (.ultraMoon, 0x0008000000),
            (.letsGoPikachu, 0x0010000000),
            (.letsGoEevee, 0x0020000000),
            (.sword, 0x0040000000),
            (.shield, 0x0080000000),
            (.brilliantDiamond, 0x0100000000),
            (.shiningPearl, 0x0200000000),
            (.legendsArceus, 0x0400000000),
            (.scarlet, 0x0800000000),
            (.violet, 0x1000000000)
        ]

        XCTAssertEqual(expectedValues.map(\.0), Game.releasedGames.sorted())
        for (game, expectedValue) in expectedValues {
            XCTAssertEqual(game.bitwiseValue, expectedValue, "Unexpected persisted value for \(game)")
        }
    }

    func testReleasedGameValuesAreUniqueSingleBits() {
        let values = Game.releasedGames.map(\.bitwiseValue)

        XCTAssertEqual(Set(values).count, values.count)
        XCTAssertTrue(values.allSatisfy { value in
            value > 0 && value & (value - 1) == 0
        })
    }

    func testNationalHasNoPersistedPurchaseBit() {
        XCTAssertEqual(Game.national.bitwiseValue, 0)
    }
}
