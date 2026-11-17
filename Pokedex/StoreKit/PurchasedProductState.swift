//
//  PurchasedProductState.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/26/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Dependencies
import Foundation
import Combine
import StoreKit
import AppSupport

private let purchasedKey = "PurchasedProductState.purchasedKey"

/// The remote purchase-state interface keeps cloud persistence separate from
/// notification delivery and app-group storage.
@MainActor
protocol PurchaseStateCloudStore: AnyObject {
    var notificationObject: AnyObject { get }
    func longLong(forKey key: String) -> Int64
    func set(_ value: Int64, forKey key: String)
    func synchronize() -> Bool
}

@MainActor
private final class UbiquitousPurchaseStateCloudStore: PurchaseStateCloudStore {
    private let store: NSUbiquitousKeyValueStore

    var notificationObject: AnyObject { store }

    init(store: NSUbiquitousKeyValueStore = .default) {
        self.store = store
    }

    func longLong(forKey key: String) -> Int64 {
        store.longLong(forKey: key)
    }

    func set(_ value: Int64, forKey key: String) {
        store.set(value, forKey: key)
    }

    func synchronize() -> Bool {
        store.synchronize()
    }
}

@MainActor
private final class IsolatedTestHostPurchaseStateCloudStore: PurchaseStateCloudStore {
    let notificationObject: AnyObject = NSObject()

    func longLong(forKey key: String) -> Int64 { 0 }
    func set(_ value: Int64, forKey key: String) { }
    func synchronize() -> Bool { true }
}

/// App-owned main-actor purchase state published to SwiftUI.
@MainActor
final class PurchasedProductState: ObservableObject {

    // MARK: Properties

    @AppGroupStorage(key: purchasedKey, defaultValue: PokepediaProduct.defaultPurchaseValue)
    var purchaseState: Int64 {
        willSet {
            objectWillChange.send()
        }
    }

    private var cancellables = Set<AnyCancellable>()
    private let cloudStore: any PurchaseStateCloudStore
    private let notificationCenter: NotificationCenter

    // MARK: Init

    init(
        appGroupDefaults: UserDefaults = .appGroup,
        cloudStore: (any PurchaseStateCloudStore)? = nil,
        notificationCenter: NotificationCenter = .default
    ) {
        self.cloudStore = cloudStore ?? UbiquitousPurchaseStateCloudStore()
        self.notificationCenter = notificationCenter
        self._purchaseState = AppGroupStorage(
            key: purchasedKey,
            defaultValue: PokepediaProduct.defaultPurchaseValue,
            store: appGroupDefaults
        )
        setupObservers()
        _ = self.cloudStore.synchronize()
    }

    /// Uses isolated stores when the app is launched as the host for unit tests.
    static func applicationDefault() -> PurchasedProductState {
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            let suiteName = "com.danielbyon.pokepedia.tests.app-host"
            guard let defaults = UserDefaults(suiteName: suiteName) else {
                fatalError("Unable to create isolated app-host purchase defaults")
            }
            defaults.removePersistentDomain(forName: suiteName)
            return PurchasedProductState(
                appGroupDefaults: defaults,
                cloudStore: IsolatedTestHostPurchaseStateCloudStore(),
                notificationCenter: NotificationCenter()
            )
        }
        return PurchasedProductState()
    }

    // MARK: Public Methods

    func hasPurchasedGame(_ game: Game) -> Bool {
        #if DEBUG
        return true
        #else
        return Self.gameAccessAllowed(game: game, purchaseState: purchaseState)
        #endif
    }

    /// Evaluates the persisted bitmask rule used by non-Debug game access.
    static func gameAccessAllowed(game: Game, purchaseState: Int64) -> Bool {
        game.bitwiseValue & purchaseState == game.bitwiseValue
    }

    func hasPurchasedProduct(_ pokepediaProduct: PokepediaProduct) -> Bool {
        pokepediaProduct.bitwiseValue & purchaseState == pokepediaProduct.bitwiseValue
    }

    func processPurchasedProductIdentifier(_ productIdentifier: String) {
        updateLocalPurchaseState(fromProductIdentifier: productIdentifier)
        pushLocalStateToRemote()
    }

    // MARK: Private Methods

    private func setupObservers() {
        cancellables.insert(notificationCenter
            .publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: cloudStore.notificationObject)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                self.updateLocalPurchaseStateFromRemote()
        })
        cancellables.insert(notificationCenter
            .publisher(for: StoreClient.purchasedNotification)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] notification in
                debugPrint("Received purchase notification")
                guard let transaction = notification.userInfo?[StoreClient.transactionUserInfoKey] as? SKPaymentTransaction else {
                    assertionFailure()
                    return
                }
                debugPrint("Processing transaction")
                let productIdentifier = transaction.payment.productIdentifier
                self.processPurchasedProductIdentifier(productIdentifier)
        })
    }

    private func updateLocalPurchaseStateFromRemote() {
        let remoteValue = cloudStore.longLong(forKey: purchasedKey)
        updateLocalPurchaseState(mergingValue: remoteValue)
    }

    private func updateLocalPurchaseState(fromProductIdentifier productIdentifier: String) {
        guard let pokepediaProduct = PokepediaProduct(rawValue: productIdentifier) else { return }
        let purchasedValue = pokepediaProduct.bitwiseValue
        guard purchasedValue > 0 else { return } // Don't update for tips
        updateLocalPurchaseState(mergingValue: purchasedValue)
    }

    private func updateLocalPurchaseState(mergingValue value: Int64) {
        // Get the local value
        let localValue = self.purchaseState
        debugPrint("Updating local value \(localValue), merging value \(value)")

        // Update the local value using logical OR
        self.purchaseState = localValue | value
    }

    private func pushLocalStateToRemote() {
        cloudStore.set(purchaseState, forKey: purchasedKey)
        _ = cloudStore.synchronize()
    }

}

private enum PurchasedProductStateKey: DependencyKey {
    static var liveValue: PurchasedProductState {
        fatalError("PurchasedProductState must be supplied by the application composition root.")
    }

    static var testValue: PurchasedProductState {
        fatalError("Tests must inject an isolated PurchasedProductState instance.")
    }
}

extension DependencyValues {
    var purchasedProductState: PurchasedProductState {
        get { self[PurchasedProductStateKey.self] }
        set { self[PurchasedProductStateKey.self] = newValue }
    }
}
