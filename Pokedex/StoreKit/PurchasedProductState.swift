//
//  PurchasedProductState.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/26/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import Combine
import StoreKit
import AppSupport

private let purchasedKey = "PurchasedProductState.purchasedKey"

final class PurchasedProductState: ObservableObject {

    // MARK: Properties

    @AppGroupStorage(key: purchasedKey, defaultValue: PokepediaProduct.defaultPurchaseValue)
    var purchaseState: Int64 {
        willSet {
            objectWillChange.send()
        }
    }

    private var cancellables = Set<AnyCancellable>()

    // MARK: Init

    init() {
        setupObservers()
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    // MARK: Public Methods

    func hasPurchasedGame(_ game: Game) -> Bool {
        #if DEBUG
        return true
        #else
        return game.bitwiseValue & purchaseState == game.bitwiseValue
        #endif
    }

    func hasPurchasedProduct(_ pokepediaProduct: PokepediaProduct) -> Bool {
        pokepediaProduct.bitwiseValue & purchaseState == pokepediaProduct.bitwiseValue
    }

    // MARK: Private Methods

    private func setupObservers() {
        cancellables.insert(NotificationCenter.default
            .publisher(for: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: NSUbiquitousKeyValueStore.default)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                self.updateLocalPurchaseStateFromRemote()
        })
        cancellables.insert(NotificationCenter.default
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
                self.updateLocalPurchaseState(fromProductIdentifier: productIdentifier)
                self.pushLocalStateToRemote()
        })
    }

    private func updateLocalPurchaseStateFromRemote() {
        let remoteValue = NSUbiquitousKeyValueStore.default.longLong(forKey: purchasedKey)
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
        NSUbiquitousKeyValueStore.default.set(purchaseState, forKey: purchasedKey)
        NSUbiquitousKeyValueStore.default.synchronize()
    }

}
