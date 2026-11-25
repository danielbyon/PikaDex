import Dependencies
import Foundation
import Intents
import PokedexCore
import XCTest
@testable import PikaDex

final class TeamIntentHandlerTests: XCTestCase {

    func testCompletionRunsOnceWithSectionsInSelectableGameOrder() throws {
        let teams = Dictionary(uniqueKeysWithValues: Game.selectableGames.map { ($0, [Team]()) })
        let storage = RecordingTeamStorage(teamsByGame: teams)
        let completion = HandlerCompletionRecorder()

        withDependencies {
            $0.teamStorage = storage
        } operation: {
            let handler = IntentHandler()
            handler.provideTeamOptionsCollection(for: TeamConfigurationIntent()) {
                completion.record($0, $1)
            }
            XCTAssertTrue(handler.handler(for: TeamConfigurationIntent()) as? IntentHandler === handler)
        }

        let result = completion.snapshot()
        XCTAssertEqual(result.callCount, 1)
        XCTAssertNil(result.error)

        let collection = try XCTUnwrap(result.collection)
        XCTAssertEqual(
            collection.sections.map(\.title),
            Game.selectableGames.map { "Pokémon \($0.title)" }
        )
        XCTAssertTrue(collection.sections.allSatisfy { $0.items.isEmpty })
        XCTAssertEqual(storage.loadedGames, Game.selectableGames)
    }

    func testNilStorageResultsAreOmittedAndStoredEmptyCollectionsKeepASection() throws {
        let storage = RecordingTeamStorage(teamsByGame: [.sword: []])
        let completion = HandlerCompletionRecorder()

        withDependencies {
            $0.teamStorage = storage
        } operation: {
            IntentHandler().provideTeamOptionsCollection(for: TeamConfigurationIntent()) {
                completion.record($0, $1)
            }
        }

        let result = completion.snapshot()
        XCTAssertEqual(result.callCount, 1)
        XCTAssertNil(result.error)

        let collection = try XCTUnwrap(result.collection)
        XCTAssertEqual(collection.sections.map(\.title), ["Pokémon \(Game.sword.title)"])
        XCTAssertTrue(collection.sections[0].items.isEmpty)
        XCTAssertEqual(storage.loadedGames, Game.selectableGames)
    }

    func testTeamOptionsPreserveIdentityTextAndWidgetSelectionCompatibility() throws {
        var standardMember = Team.stub1.members[0]
        standardMember.pokemon = "Pikachu"
        standardMember.formName = "Pikachu"

        var regionalMember = Team.stub1.members[1]
        regionalMember.pokemon = "Raichu"
        regionalMember.formName = "Alolan"

        let teamID = UUID(uuidString: "00000000-0000-0000-0000-000000000021")!
        let team = Team(
            name: "Regional team",
            members: [standardMember, regionalMember],
            internalID: teamID
        )
        let storage = RecordingTeamStorage(teamsByGame: [.shield: [team]])
        let completion = HandlerCompletionRecorder()

        withDependencies {
            $0.teamStorage = storage
        } operation: {
            IntentHandler().provideTeamOptionsCollection(for: TeamConfigurationIntent()) {
                completion.record($0, $1)
            }
        }

        let result = completion.snapshot()
        XCTAssertEqual(result.callCount, 1)
        XCTAssertNil(result.error)

        let collection = try XCTUnwrap(result.collection)
        let section = try XCTUnwrap(collection.sections.first)
        XCTAssertEqual(section.title, "Pokémon \(Game.shield.title)")

        let option = try XCTUnwrap(section.items.first)
        XCTAssertEqual(option.identifier, teamID.uuidString)
        XCTAssertEqual(option.displayString, team.name)
        XCTAssertEqual(option.subtitleString, "Pikachu, Raichu-Alolan")
        XCTAssertEqual(option.game, Game.shield.rawValue)
        XCTAssertEqual(storage.loadedGames, Game.selectableGames)

        let resolver = TeamEntryResolver(storage: storage, loadCurrentGame: { .shield })
        let entry = resolver.configuredEntry(
            gameRawValue: option.game,
            teamIdentifier: option.identifier,
            date: Date(timeIntervalSince1970: 21)
        )
        XCTAssertEqual(entry.teamName, team.name)
        XCTAssertEqual(entry.teamID, teamID.uuidString)
        XCTAssertEqual(entry.game, Game.shield.rawValue)
    }

    func testCallbackRunsOffMainWhenInvokedOffMain() async {
        let storage = RecordingTeamStorage(teamsByGame: [:])
        let completion = HandlerCompletionRecorder()

        await Task.detached {
            withDependencies {
                $0.teamStorage = storage
            } operation: {
                IntentHandler().provideTeamOptionsCollection(for: TeamConfigurationIntent()) {
                    completion.record($0, $1)
                }
            }
        }.value

        let result = completion.snapshot()
        XCTAssertEqual(result.callCount, 1)
        XCTAssertNil(result.error)
        XCTAssertEqual(result.callbackWasMainThread, false)
    }

    func testGeneratedIntentTypesResolveFromTheHostApplication() {
        let intentBundle = Bundle(for: TeamConfigurationIntent.self)
        let teamBundle = Bundle(for: DynamicTeam.self)

        XCTAssertEqual(intentBundle.bundleIdentifier, "com.danielbyon.pokepedia")
        XCTAssertEqual(teamBundle.bundleIdentifier, "com.danielbyon.pokepedia")
        XCTAssertNotNil(NSClassFromString(NSStringFromClass(TeamConfigurationIntent.self)))
        XCTAssertNotNil(NSClassFromString(NSStringFromClass(DynamicTeam.self)))
    }

}

private struct HandlerCompletionSnapshot {
    let callCount: Int
    let collection: INObjectCollection<DynamicTeam>?
    let error: Error?
    let callbackWasMainThread: Bool?
}

private final class HandlerCompletionRecorder: @unchecked Sendable {

    private let lock = NSLock()
    private var callCount = 0
    private var collection: INObjectCollection<DynamicTeam>?
    private var error: Error?
    private var callbackWasMainThread: Bool?

    func record(_ collection: INObjectCollection<DynamicTeam>?, _ error: Error?) {
        lock.withLock {
            callCount += 1
            self.collection = collection
            self.error = error
            callbackWasMainThread = Thread.isMainThread
        }
    }

    func snapshot() -> HandlerCompletionSnapshot {
        lock.withLock {
            HandlerCompletionSnapshot(
                callCount: callCount,
                collection: collection,
                error: error,
                callbackWasMainThread: callbackWasMainThread
            )
        }
    }

}

/// A lock-protected fixture that records the games read by the handler.
private final class RecordingTeamStorage: TeamStorage, @unchecked Sendable {

    private let lock = NSLock()
    private var teamsByGame: [Game: [Team]]
    private var reads: [Game] = []

    init(teamsByGame: [Game: [Team]]) {
        self.teamsByGame = teamsByGame
    }

    var loadedGames: [Game] {
        lock.withLock { reads }
    }

    func loadTeams(forGame game: Game) -> [Team]? {
        lock.withLock {
            reads.append(game)
            return teamsByGame[game]
        }
    }

    func saveTeams(_ teams: [Team], forGame game: Game) {
        lock.withLock {
            teamsByGame[game] = teams
        }
    }

}
