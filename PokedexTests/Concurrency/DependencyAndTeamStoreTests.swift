import Foundation
import Dependencies
import PokedexCore
import StoreKit
import SwiftUI
import UIKit
import XCTest
@testable import PikaDex

@MainActor
final class DependencyAndTeamStoreTests: XCTestCase {

    func testAppDependencyScopeReusesExactInstancesAcrossRepeatedCompositions() throws {
        let settings = AppSettings()
        let purchaseHarness = PurchasedProductStateTestHarness()
        defer { purchaseHarness.cleanUp() }
        let purchasedProductState = purchaseHarness.state
        let persistenceStores = try PersistenceBootstrap.makeInMemoryForTesting()
        let teamStore = DefaultTeamStore(storage: VolatileTeamStorage(), debounceInterval: 60)
        let storeClient = TestStoreClient()
        let dependencyScope = AppDependencyScope(
            storeClientReference: StoreClientReference(storeClient)
        )

        let compose = {
            dependencyScope.withValues(
                appSettings: settings,
                purchasedProductState: purchasedProductState,
                teamStore: teamStore,
                persistenceStores: persistenceStores
            ) {
                @Dependency(\.appSettings) var resolvedSettings
                @Dependency(\.purchasedProductState) var resolvedPurchaseState
                @Dependency(\.storeClient) var resolvedStoreClient
                @Dependency(\.teamStore) var resolvedTeamStore
                @Dependency(\.pokedexDataStore) var resolvedPokedexDataStore
                @Dependency(\.userDataDataStore) var resolvedUserDataDataStore

                return (
                    appSettings: resolvedSettings,
                    purchasedProductState: resolvedPurchaseState,
                    storeClientReference: resolvedStoreClient,
                    teamStore: resolvedTeamStore,
                    pokedexDataStore: resolvedPokedexDataStore,
                    userDataDataStore: resolvedUserDataDataStore
                )
            }
        }

        let first = compose()
        let second = compose()

        for resolved in [first, second] {
            XCTAssertTrue(resolved.appSettings === settings)
            XCTAssertTrue(resolved.purchasedProductState === purchasedProductState)
            XCTAssertTrue(resolved.storeClientReference === dependencyScope.storeClientReference)
            XCTAssertTrue((resolved.storeClientReference.client as AnyObject) === storeClient)
            XCTAssertTrue((resolved.teamStore as AnyObject) === teamStore)
            XCTAssertTrue(resolved.pokedexDataStore === persistenceStores.pokedex)
            XCTAssertTrue(resolved.userDataDataStore === persistenceStores.userData)
        }
    }

    func testProductIdentifiersAndPurchaseMasksRemainStable() {
        let expected: [(PokepediaProduct, String, Int64)] = [
            (.all3DSGames, "com.danielbyon.pokepedia.iap.all3dsgames", 267_386_880),
            (.allDSGames, "com.danielbyon.pokepedia.iap.alldsgames", 1_046_528),
            (.allGameBoyGames, "com.danielbyon.pokepedia.iap.allgameboygames", 2_047),
            (.allSwitchGames, "com.danielbyon.pokepedia.iap.allswitchgames", 137_170_518_016),
            (.allGames, "com.danielbyon.pokepedia.iap.allgames", 137_438_953_471),
            (.generation1, "com.danielbyon.pokepedia.iap.generation1", 7),
            (.generation2, "com.danielbyon.pokepedia.iap.generation2", 56),
            (.rubySapphireEmerald, "com.danielbyon.pokepedia.iap.rubysapphireemerald", 448),
            (.fireRedLeafGreen, "com.danielbyon.pokepedia.iap.fireredleafgreen", 1_536),
            (.diamondPearlPlatinum, "com.danielbyon.pokepedia.iap.diamondpearlplatinum", 14_336),
            (.heartGoldSoulSilver, "com.danielbyon.pokepedia.iap.heartgoldsoulsilver", 49_152),
            (.blackWhite, "com.danielbyon.pokepedia.iap.blackwhite", 196_608),
            (.black2White2, "com.danielbyon.pokepedia.iap.black2white2", 786_432),
            (.xY, "com.danielbyon.pokepedia.iap.xy", 3_145_728),
            (.omegaRubyAlphaSapphire, "com.danielbyon.pokepedia.iap.omegarubyalphasapphire", 12_582_912),
            (.sunMoon, "com.danielbyon.pokepedia.iap.sunmoon", 50_331_648),
            (.ultraSunUltraMoon, "com.danielbyon.pokepedia.iap.ultrasunultramoon", 201_326_592),
            (.letsGoPikachuLetsGoEevee, "com.danielbyon.pokepedia.iap.letsgopikachuletsgoeevee", 805_306_368),
            (.swordShield, "com.danielbyon.pokepedia.iap.swordshield", 3_221_225_472),
            (.smallTip, "com.danielbyon.pokepedia.iap.tipjarsmall", 0),
            (.mediumTip, "com.danielbyon.pokepedia.iap.tipjarmedium", 0),
            (.largeTip, "com.danielbyon.pokepedia.iap.tipjarlarge", 0)
        ]

        for (product, identifier, mask) in expected {
            XCTAssertEqual(product.productIdentifier, identifier)
            XCTAssertEqual(product.bitwiseValue, mask, product.rawValue)
        }
    }

    func testPersistedPurchaseBitsKeepJSONEncodingAndMergeByOr() throws {
        let original = PokepediaProduct.generation1.bitwiseValue
        let harness = PurchasedProductStateTestHarness(persistedPurchaseState: original)
        defer { harness.cleanUp() }

        XCTAssertEqual(harness.state.purchaseState, original)
        XCTAssertTrue(harness.state.hasPurchasedProduct(.generation1))

        harness.state.processPurchasedProductIdentifier(PokepediaProduct.generation2.productIdentifier)

        let merged = original | PokepediaProduct.generation2.bitwiseValue
        XCTAssertEqual(harness.state.purchaseState, merged)
        XCTAssertEqual(harness.cloudStore.writtenValues, [merged])
        XCTAssertEqual(harness.cloudStore.writtenKeys, [harness.purchaseStateKey])
        XCTAssertEqual(harness.cloudStore.synchronizeCount, 2)

        let persistedData = try XCTUnwrap(harness.defaults.data(forKey: harness.purchaseStateKey))
        XCTAssertEqual(try JSONDecoder().decode(Int64.self, from: persistedData), merged)
    }

    func testTipPurchaseKeepsPurchaseMaskAtZero() {
        let harness = PurchasedProductStateTestHarness()
        defer { harness.cleanUp() }

        harness.state.processPurchasedProductIdentifier(PokepediaProduct.smallTip.productIdentifier)

        XCTAssertEqual(harness.state.purchaseState, 0)
        XCTAssertEqual(harness.cloudStore.writtenValues, [0])
    }

    func testExternalCloudChangeNotificationMergesFromInjectedStoreAndFiltersObject() async {
        let original = PokepediaProduct.generation1.bitwiseValue
        let remote = PokepediaProduct.generation2.bitwiseValue
        let harness = PurchasedProductStateTestHarness(
            persistedPurchaseState: original,
            remotePurchaseState: remote
        )
        defer { harness.cleanUp() }
        let firstRead = expectation(description: "The matching external-change notification reads cloud state")
        harness.cloudStore.onRead = { key in
            XCTAssertEqual(key, harness.purchaseStateKey)
            if harness.cloudStore.readKeys.count == 1 {
                firstRead.fulfill()
            }
        }

        harness.notificationCenter.post(
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: NSObject()
        )
        harness.notificationCenter.post(
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: harness.cloudStore.notificationObject
        )

        await fulfillment(of: [firstRead], timeout: 2)
        let mainQueueDrained = expectation(description: "All queued notification deliveries have run")
        DispatchQueue.main.async { mainQueueDrained.fulfill() }
        await fulfillment(of: [mainQueueDrained], timeout: 2)

        XCTAssertEqual(harness.cloudStore.readKeys, [harness.purchaseStateKey])
        XCTAssertEqual(harness.state.purchaseState, original | remote)
    }

    func testGameAuthorizationCalculationUsesThePersistedPurchaseMask() {
        XCTAssertFalse(PurchasedProductState.gameAccessAllowed(game: .red, purchaseState: 0))
        XCTAssertTrue(PurchasedProductState.gameAccessAllowed(
            game: .red,
            purchaseState: Game.red.bitwiseValue
        ))
        XCTAssertFalse(PurchasedProductState.gameAccessAllowed(
            game: .red,
            purchaseState: Game.blue.bitwiseValue
        ))
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

private final class TestStoreClient: StoreClientProtocol {

    @MainActor
    func requestProducts() async throws -> [SKProduct] { [] }

    func purchaseProduct(_ product: SKProduct) { }

    func restorePurchases() { }
}

@MainActor
final class PurchasedProductStateTestHarness {

    let purchaseStateKey = "PurchasedProductState.purchasedKey"
    let suiteName: String
    let defaults: UserDefaults
    let notificationCenter: NotificationCenter
    let cloudStore: InMemoryPurchaseStateCloudStore
    let state: PurchasedProductState

    init(persistedPurchaseState: Int64 = 0, remotePurchaseState: Int64 = 0) {
        suiteName = "com.danielbyon.pokepedia.tests.purchase-state.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            fatalError("Unable to create isolated purchase-state defaults")
        }
        defaults.removePersistentDomain(forName: suiteName)
        if persistedPurchaseState != 0 {
            do {
                defaults.set(try JSONEncoder().encode(persistedPurchaseState), forKey: purchaseStateKey)
            } catch {
                fatalError("Unable to encode isolated purchase-state defaults: \(error)")
            }
        }

        self.defaults = defaults
        notificationCenter = NotificationCenter()
        cloudStore = InMemoryPurchaseStateCloudStore(value: remotePurchaseState)
        state = PurchasedProductState(
            appGroupDefaults: defaults,
            cloudStore: cloudStore,
            notificationCenter: notificationCenter
        )
    }

    func cleanUp() {
        defaults.removePersistentDomain(forName: suiteName)
    }
}

@MainActor
final class InMemoryPurchaseStateCloudStore: PurchaseStateCloudStore {

    let notificationObject: AnyObject = NSObject()
    private(set) var value: Int64
    private(set) var readKeys: [String] = []
    private(set) var writtenKeys: [String] = []
    private(set) var writtenValues: [Int64] = []
    private(set) var synchronizeCount = 0
    var onRead: ((String) -> Void)?

    init(value: Int64) {
        self.value = value
    }

    func longLong(forKey key: String) -> Int64 {
        readKeys.append(key)
        onRead?(key)
        return value
    }

    func set(_ value: Int64, forKey key: String) {
        self.value = value
        writtenKeys.append(key)
        writtenValues.append(value)
    }

    func synchronize() -> Bool {
        synchronizeCount += 1
        return true
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
