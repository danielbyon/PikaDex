import XCTest

@testable import PikaDex

final class DeepLinkTests: XCTestCase {

    func testPokemonRouteConstructionAndParsing() throws {
        let url = try XCTUnwrap(URL(pokemon: "Bulbasaur"))

        XCTAssertEqual(url.absoluteString, "pikadex://pokemon/Bulbasaur")
        XCTAssertTrue(url.isDeepLink)
        XCTAssertEqual(url.supportedHost, .pokemon)
        XCTAssertEqual(url.pokemon, "Bulbasaur")
        XCTAssertNil(url.teamID)
        XCTAssertNil(url.game)
    }

    func testTeamRouteConstructionAndParsing() throws {
        let url = try XCTUnwrap(URL(teamID: "team-123", game: "sword"))

        XCTAssertEqual(url.absoluteString, "pikadex://teams/team-123?game=sword")
        XCTAssertTrue(url.isDeepLink)
        XCTAssertEqual(url.supportedHost, .teams)
        XCTAssertEqual(url.teamID, "team-123")
        XCTAssertNil(url.pokemon)
        XCTAssertEqual(url.game, .sword)
    }

    func testSchemeValidationIsIndependentOfSupportedHost() throws {
        let url = try XCTUnwrap(URL(string: "https://pokemon/Bulbasaur"))

        XCTAssertFalse(url.isDeepLink)
        XCTAssertEqual(url.supportedHost, .pokemon)
    }

    func testUnsupportedAndMissingHostsDoNotProduceRoutes() throws {
        let unsupported = try XCTUnwrap(URL(string: "pikadex://settings/account"))
        let missing = try XCTUnwrap(URL(string: "pikadex:///Bulbasaur"))

        for url in [unsupported, missing] {
            XCTAssertNil(url.supportedHost)
            XCTAssertNil(url.pokemon)
            XCTAssertNil(url.teamID)
        }
    }

    func testMissingAndMalformedGameValuesAreRejected() throws {
        let constructedWithoutGame = try XCTUnwrap(URL(teamID: "team-123", game: nil))
        XCTAssertEqual(constructedWithoutGame.absoluteString, "pikadex://teams/team-123?game=")
        XCTAssertNil(constructedWithoutGame.game)

        let urls = [
            "pikadex://teams/team-123",
            "pikadex://teams/team-123?game=",
            "pikadex://teams/team-123?game=not-a-game",
            "pikadex://teams/team-123?other=sword"
        ]

        for value in urls {
            XCTAssertNil(try XCTUnwrap(URL(string: value)).game, value)
        }
    }

    func testMissingPathsExposeTheCurrentEmptyRouteValue() throws {
        let pokemon = try XCTUnwrap(URL(string: "pikadex://pokemon"))
        let team = try XCTUnwrap(URL(string: "pikadex://teams"))

        XCTAssertEqual(pokemon.pokemon, "")
        XCTAssertEqual(team.teamID, "")
    }
}
