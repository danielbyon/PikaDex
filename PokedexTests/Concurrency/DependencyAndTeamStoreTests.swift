import Dependencies
import PokedexCore
import XCTest
@testable import PikaDex

@MainActor
final class DependencyAndTeamStoreTests: XCTestCase {

    func testCompositionResolvesExactObservableInstances() {
        let settings = AppSettings()
        let purchasedProductState = PurchasedProductState()

        withDependencies {
            $0.appSettings = settings
            $0.purchasedProductState = purchasedProductState
        } operation: {
            @Dependency(\.appSettings) var firstSettings
            @Dependency(\.purchasedProductState) var firstPurchaseState
            XCTAssertTrue(firstSettings === settings)
            XCTAssertTrue(firstPurchaseState === purchasedProductState)

            @Dependency(\.appSettings) var secondSettings
            @Dependency(\.purchasedProductState) var secondPurchaseState
            XCTAssertTrue(secondSettings === firstSettings)
            XCTAssertTrue(secondPurchaseState === firstPurchaseState)
        }
    }

    func testSeparateDependencyConfigurationsDoNotShareVolatileStorage() {
        let storedCount = withDependencies {
            $0.teamStorage = VolatileTeamStorage()
        } operation: {
            @Dependency(\.teamStorage) var storage
            storage.saveTeams([Team(name: "First")], forGame: .sword)
            return storage.loadTeams(forGame: .sword)?.count
        }

        let isolatedCount = withDependencies {
            $0.teamStorage = VolatileTeamStorage()
        } operation: {
            @Dependency(\.teamStorage) var storage
            return storage.loadTeams(forGame: .sword)?.count
        }

        XCTAssertEqual(storedCount, 1)
        XCTAssertNil(isolatedCount)
    }

    func testExplicitFlushPersistsLatestSnapshotSynchronously() {
        let storage = RecordingTeamStorage()
        let store = DefaultTeamStore(storage: storage, debounceInterval: 60)
        store.setTeams([Team(name: "Old")], forGame: .sword)
        store.setTeams([Team(name: "Latest")], forGame: .sword)

        store.flushPendingWrites()

        XCTAssertEqual(storage.savedTeams(for: .sword)?.map(\.name), ["Latest"])
        XCTAssertEqual(storage.saveCount, 1)
    }

    func testTeardownIntentionallyDiscardsUnflushedSnapshot() async {
        let storage = RecordingTeamStorage()
        var store: DefaultTeamStore? = DefaultTeamStore(storage: storage, debounceInterval: 0.01)
        store?.setTeams([Team(name: "Pending")], forGame: .sword)

        store = nil
        try? await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(storage.saveCount, 0)
    }

    func testImmutableNumberFormatsPreserveDisplayOutput() {
        XCTAssertEqual(PokedexNumberFormat.twoDigit.format(1), "01")
        XCTAssertEqual(PokedexNumberFormat.pokemonIndex.format(25), "025")
        XCTAssertEqual(PokedexNumberFormat.oneDecimal.format(87.5), "87.5")
        XCTAssertEqual(PokedexNumberFormat.wholeNumber.format(2), "2")
    }
}

private final class RecordingTeamStorage: TeamStorage {
    private let lock = NSLock()
    private var teamsByGame: [Game: [Team]] = [:]
    private var saves = 0

    var saveCount: Int {
        lock.withLock { saves }
    }

    func loadTeams(forGame game: Game) -> [Team]? {
        lock.withLock { teamsByGame[game] }
    }

    func saveTeams(_ teams: [Team], forGame game: Game) {
        lock.withLock {
            teamsByGame[game] = teams
            saves += 1
        }
    }

    func savedTeams(for game: Game) -> [Team]? {
        lock.withLock { teamsByGame[game] }
    }
}
