import Foundation
import PokedexCore
import XCTest

final class TeamEntryResolverTests: XCTestCase {

    func testConfiguredTeamUsesConfiguredGameAndStableTeamIdentifier() {
        let storage = VolatileTeamStorage()
        let fallback = Team(name: "Sword fallback", internalID: uuid("00000000-0000-0000-0000-000000000001"))
        let configured = team(
            name: "Shield team",
            id: uuid("00000000-0000-0000-0000-000000000002"),
            pokemon: [("Pikachu", "Pikachu")]
        )
        storage.saveTeams([fallback], forGame: .sword)
        storage.saveTeams([configured], forGame: .shield)

        let date = Date(timeIntervalSince1970: 123)
        let resolver = makeResolver(storage: storage, currentGame: .sword)
        let entry = resolver.configuredEntry(
            gameRawValue: Game.shield.rawValue,
            teamIdentifier: configured.internalID.uuidString,
            date: date
        )

        XCTAssertEqual(entry.teamName, "Shield team")
        XCTAssertEqual(entry.teamID, "00000000-0000-0000-0000-000000000002")
        XCTAssertEqual(entry.game, "shield")
        XCTAssertEqual(entry.teamMemberNames, ["Pikachu"])
        XCTAssertEqual(entry.teamMemberSpriteNames, ["025-menusprite"])
        XCTAssertEqual(entry.date, date)
    }

    func testMissingConfigurationFallsBackToFirstCurrentGameTeam() {
        let storage = VolatileTeamStorage()
        let first = Team(name: "First", internalID: uuid("00000000-0000-0000-0000-000000000003"))
        let second = Team(name: "Second", internalID: uuid("00000000-0000-0000-0000-000000000004"))
        storage.saveTeams([first, second], forGame: .scarlet)

        let entry = makeResolver(storage: storage, currentGame: .scarlet)
            .configuredEntry(gameRawValue: nil, teamIdentifier: nil, date: fixedDate)

        XCTAssertEqual(entry.teamName, "First")
        XCTAssertEqual(entry.teamID, first.internalID.uuidString)
        XCTAssertNil(entry.game)
    }

    func testInvalidGameConfigurationFallsBackToCurrentGame() {
        let storage = VolatileTeamStorage()
        let fallback = Team(name: "Current game team", internalID: uuid("00000000-0000-0000-0000-000000000005"))
        storage.saveTeams([fallback], forGame: .violet)

        let entry = makeResolver(storage: storage, currentGame: .violet)
            .configuredEntry(gameRawValue: "unknown-game", teamIdentifier: "anything", date: fixedDate)

        XCTAssertEqual(entry.teamName, "Current game team")
        XCTAssertNil(entry.game)
    }

    func testUnmatchedTeamConfigurationFallsBackToCurrentGame() {
        let storage = VolatileTeamStorage()
        storage.saveTeams([Team(name: "Configured game's first team")], forGame: .sword)
        let fallback = Team(name: "Current game's first team", internalID: uuid("00000000-0000-0000-0000-000000000006"))
        storage.saveTeams([fallback], forGame: .shield)

        let entry = makeResolver(storage: storage, currentGame: .shield)
            .configuredEntry(gameRawValue: Game.sword.rawValue, teamIdentifier: "missing-id", date: fixedDate)

        XCTAssertEqual(entry.teamName, "Current game's first team")
        XCTAssertEqual(entry.teamID, fallback.internalID.uuidString)
        XCTAssertNil(entry.game)
    }

    func testMissingAndEmptyStorageProduceEmptyEntries() {
        let missingEntry = makeResolver(storage: VolatileTeamStorage(), currentGame: .sword)
            .configuredEntry(gameRawValue: nil, teamIdentifier: nil, date: fixedDate)

        let emptyStorage = VolatileTeamStorage()
        emptyStorage.saveTeams([], forGame: .sword)
        let emptyEntry = makeResolver(storage: emptyStorage, currentGame: .sword)
            .configuredEntry(gameRawValue: nil, teamIdentifier: nil, date: fixedDate)

        for entry in [missingEntry, emptyEntry] {
            XCTAssertNil(entry.teamName)
            XCTAssertTrue(entry.teamMemberNames.isEmpty)
            XCTAssertTrue(entry.teamMemberSpriteNames.isEmpty)
            XCTAssertEqual(entry.teamID, "")
            XCTAssertNil(entry.game)
            XCTAssertEqual(entry.date, fixedDate)
        }
    }

    func testPlaceholderUsesFirstTeamFromOneCurrentGameSnapshot() {
        let storage = VolatileTeamStorage()
        let first = Team(name: "First placeholder team")
        storage.saveTeams([first], forGame: .shield)
        let loader = LockedGameLoader(.shield)
        let resolver = TeamEntryResolver(storage: storage, loadCurrentGame: { loader.load() })

        let entry = resolver.placeholderEntry(date: fixedDate)

        XCTAssertEqual(entry.teamName, "First placeholder team")
        XCTAssertNil(entry.game)
        XCTAssertEqual(entry.date, fixedDate)
        XCTAssertEqual(loader.count, 1)
    }

    func testEachResolverOperationLoadsCurrentGameExactlyOnce() {
        let storage = VolatileTeamStorage()
        let configured = Team(name: "Configured", internalID: uuid("00000000-0000-0000-0000-000000000007"))
        storage.saveTeams([configured], forGame: .scarlet)
        let loader = LockedGameLoader(.sword)
        let resolver = TeamEntryResolver(storage: storage, loadCurrentGame: { loader.load() })

        _ = resolver.configuredEntry(
            gameRawValue: Game.scarlet.rawValue,
            teamIdentifier: configured.internalID.uuidString,
            date: fixedDate
        )
        XCTAssertEqual(loader.count, 1)

        _ = resolver.placeholderEntry(date: fixedDate)
        XCTAssertEqual(loader.count, 2)
    }

    func testEntryRemainsAnImmutableSnapshotAfterStorageChanges() {
        let storage = VolatileTeamStorage()
        let id = uuid("00000000-0000-0000-0000-000000000008")
        storage.saveTeams([team(name: "Before", id: id, pokemon: [("Pikachu", "Pikachu")])], forGame: .scarlet)
        let resolver = makeResolver(storage: storage, currentGame: .sword)

        let original = resolver.configuredEntry(
            gameRawValue: Game.scarlet.rawValue,
            teamIdentifier: id.uuidString,
            date: fixedDate
        )
        storage.saveTeams([team(name: "After", id: id, pokemon: [("Bulbasaur", "Ivysaur")])], forGame: .scarlet)
        let updated = resolver.configuredEntry(
            gameRawValue: Game.scarlet.rawValue,
            teamIdentifier: id.uuidString,
            date: fixedDate
        )

        XCTAssertEqual(original.teamName, "Before")
        XCTAssertEqual(original.teamMemberNames, ["Pikachu"])
        XCTAssertEqual(original.teamMemberSpriteNames, ["025-menusprite"])
        XCTAssertEqual(updated.teamName, "After")
        XCTAssertEqual(updated.teamMemberNames, ["Bulbasaur"])
        XCTAssertEqual(updated.teamMemberSpriteNames, ["001-Ivysaur-menusprite"])
    }

    func testRepeatedAndConcurrentOperationsReturnConsistentEntries() {
        let storage = VolatileTeamStorage()
        let expected = Team(name: "Stable", internalID: uuid("00000000-0000-0000-0000-000000000009"))
        storage.saveTeams([expected], forGame: .sword)
        let loader = LockedGameLoader(.sword)
        let resolver = TeamEntryResolver(storage: storage, loadCurrentGame: { loader.load() })
        let results = LockedStringResults()

        for _ in 0..<8 {
            XCTAssertEqual(
                resolver.configuredEntry(gameRawValue: nil, teamIdentifier: nil, date: fixedDate).teamID,
                expected.internalID.uuidString
            )
        }

        let concurrentDate = fixedDate
        DispatchQueue.concurrentPerform(iterations: 32) { _ in
            let entry = resolver.configuredEntry(gameRawValue: nil, teamIdentifier: nil, date: concurrentDate)
            results.append(entry.teamID)
        }

        XCTAssertEqual(results.values.count, 32)
        XCTAssertTrue(results.values.allSatisfy { $0 == expected.internalID.uuidString })
        XCTAssertEqual(loader.count, 40)
    }

    func testPersistedGameDecodingAndSwordFallback() throws {
        let persistedGame = try JSONEncoder().encode(Game.violet)

        XCTAssertEqual(TeamEntryResolver.decodePersistedGame(from: persistedGame), .violet)
        XCTAssertEqual(TeamEntryResolver.decodePersistedGame(from: nil), .sword)
        XCTAssertEqual(TeamEntryResolver.decodePersistedGame(from: Data("invalid".utf8)), .sword)
    }

    private var fixedDate: Date { Date(timeIntervalSince1970: 456) }

    private func makeResolver(storage: any TeamStorage, currentGame: Game) -> TeamEntryResolver {
        TeamEntryResolver(storage: storage, loadCurrentGame: { currentGame })
    }

    private func team(name: String, id: UUID, pokemon: [(String, String)]) -> Team {
        let members = pokemon.map { pokemonName, formName in
            var member = Team.stub1.members[0]
            member.pokemon = pokemonName
            member.formName = formName
            return member
        }
        return Team(name: name, members: members, internalID: id)
    }

    private func uuid(_ value: String) -> UUID {
        UUID(uuidString: value)!
    }

}

private final class LockedGameLoader: @unchecked Sendable {
    private let lock = NSLock()
    private let game: Game
    private var loadCount = 0

    init(_ game: Game) {
        self.game = game
    }

    func load() -> Game {
        lock.lock()
        defer { lock.unlock() }
        loadCount += 1
        return game
    }

    var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return loadCount
    }
}

private final class LockedStringResults: @unchecked Sendable {
    private let lock = NSLock()
    private var storedValues: [String] = []

    func append(_ value: String) {
        lock.lock()
        defer { lock.unlock() }
        storedValues.append(value)
    }

    var values: [String] {
        lock.lock()
        defer { lock.unlock() }
        return storedValues
    }
}
