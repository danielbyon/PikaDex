import Foundation
import Dependencies
import PokedexCore
import SwiftUI
import UIKit
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

    func testTeamStoreDependencyCarriesTheInjectedInstanceToAChildTask() async {
        let store = DefaultTeamStore(storage: VolatileTeamStorage(), debounceInterval: 60)
        let expectedIdentity = ObjectIdentifier(store as AnyObject)

        let resolvedIdentity = await withDependencies {
            $0.teamStore = store
        } operation: {
            await Task {
                @Dependency(\.teamStore) var resolvedStore
                return ObjectIdentifier(resolvedStore as AnyObject)
            }.value
        }

        XCTAssertEqual(resolvedIdentity, expectedIdentity)
    }

    func testSeparateDependencyConfigurationsUseTheirInjectedStorage() {
        let firstStorage = VolatileTeamStorage()
        firstStorage.saveTeams([Team(name: "First")], forGame: .sword)
        let secondStorage = VolatileTeamStorage()
        secondStorage.saveTeams([Team(name: "Second")], forGame: .sword)

        let firstTeams = withDependencies {
            $0.teamStorage = firstStorage
        } operation: {
            @Dependency(\.teamStorage) var storage
            return storage.loadTeams(forGame: .sword)
        }

        let secondTeams = withDependencies {
            $0.teamStorage = secondStorage
        } operation: {
            @Dependency(\.teamStorage) var storage
            return storage.loadTeams(forGame: .sword)
        }

        XCTAssertEqual(firstTeams?.map(\.name), ["First"])
        XCTAssertEqual(secondTeams?.map(\.name), ["Second"])
    }

    func testTestDependencyDefaultsToIsolatedVolatileStorage() {
        let firstTeams = withDependencies {
            $0 = .test
        } operation: {
            @Dependency(\.teamStorage) var storage
            XCTAssertTrue(storage is VolatileTeamStorage)
            storage.saveTeams([Team(name: "First context")], forGame: .sword)
            return storage.loadTeams(forGame: .sword)
        }

        let secondTeams = withDependencies {
            $0 = .test
        } operation: {
            @Dependency(\.teamStorage) var storage
            XCTAssertTrue(storage is VolatileTeamStorage)
            return storage.loadTeams(forGame: .sword)
        }

        XCTAssertEqual(firstTeams?.map(\.name), ["First context"])
        XCTAssertNil(secondTeams)
    }

    func testVolatileStorageKeepsConcurrentSnapshotsReadable() async {
        let storage = VolatileTeamStorage()
        let validNames = Set((0..<32).flatMap { worker in
            (0..<32).map { "Team \(worker)-\($0)" }
        })

        let invalidReadCount = await withTaskGroup(of: Bool.self, returning: Int.self) { group in
            for worker in 0..<32 {
                group.addTask {
                    for iteration in 0..<32 {
                        storage.saveTeams([Team(name: "Team \(worker)-\(iteration)")], forGame: .sword)
                        let snapshot = storage.loadTeams(forGame: .sword)
                        guard snapshot?.count == 1,
                              let name = snapshot?.first?.name,
                              validNames.contains(name)
                        else { return false }
                    }
                    return true
                }
            }

            var invalidReads = 0
            for await isValid in group where !isValid {
                invalidReads += 1
            }
            return invalidReads
        }

        XCTAssertEqual(invalidReadCount, 0)
    }

    func testAppStorageObservesWritesThroughTheAppGroupAccessor() async {
        let key = "pokedex.tests.app-group-observation.\(UUID().uuidString)"
        let readerDefaults = UserDefaults.appGroup
        let writerDefaults = UserDefaults.appGroup
        XCTAssertTrue(readerDefaults === writerDefaults)
        readerDefaults.removeObject(forKey: key)

        let appeared = expectation(description: "The preference view appeared")
        let changed = expectation(description: "AppStorage observed the shared defaults handle")
        let rootView = AppGroupPreferenceObservationView(
            key: key,
            onAppear: { appeared.fulfill() },
            onChange: { value in
                if value { changed.fulfill() }
            }
        )
        let windowScene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first
        guard let windowScene else {
            XCTFail("The test host must have an active window scene")
            return
        }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: rootView)
        window.makeKeyAndVisible()
        defer {
            window.isHidden = true
            writerDefaults.removeObject(forKey: key)
        }

        await fulfillment(of: [appeared], timeout: 2)
        writerDefaults.set(true, forKey: key)
        await fulfillment(of: [changed], timeout: 2)
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

    func testSubmittedSnapshotIsIndependentOfLaterCallerMutation() {
        let storage = RecordingTeamStorage()
        let store = DefaultTeamStore(storage: storage, debounceInterval: 60)
        var teams = [Team(name: "Submitted")]
        store.setTeams(teams, forGame: .sword)
        teams[0].name = "Mutated after submission"

        store.flushPendingWrites()

        XCTAssertEqual(storage.savedTeams(for: .sword)?.map(\.name), ["Submitted"])
        XCTAssertEqual(storage.saveCount, 1)
    }

    func testTeardownIntentionallyDiscardsUnflushedSnapshot() {
        let storage = RecordingTeamStorage()
        var store: DefaultTeamStore? = DefaultTeamStore(storage: storage, debounceInterval: 3_600)
        store?.setTeams([Team(name: "Pending")], forGame: .sword)

        store = nil

        XCTAssertEqual(storage.saveCount, 0)
    }

    func testImmutableNumberFormatsPreserveDisplayOutput() {
        XCTAssertEqual(PokedexNumberFormat.twoDigit.format(1), "01")
        XCTAssertEqual(PokedexNumberFormat.pokemonIndex.format(25), "025")
        XCTAssertEqual(PokedexNumberFormat.oneDecimal.format(87.5), "87.5")
        XCTAssertEqual(PokedexNumberFormat.wholeNumber.format(2), "2")
    }
}

@MainActor
private struct AppGroupPreferenceObservationView: View {
    @AppStorage private var isEnabled: Bool

    let onAppear: () -> Void
    let onChange: (Bool) -> Void

    init(key: String, onAppear: @escaping () -> Void, onChange: @escaping (Bool) -> Void) {
        _isEnabled = AppStorage(wrappedValue: false, key, store: .appGroup)
        self.onAppear = onAppear
        self.onChange = onChange
    }

    var body: some View {
        Text(isEnabled ? "enabled" : "disabled")
            .onAppear(perform: onAppear)
            .onChange(of: isEnabled) { _, value in onChange(value) }
    }
}

private final class RecordingTeamStorage: TeamStorage, @unchecked Sendable {
    // The lock protects every access to the recorded teams and save count.
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
