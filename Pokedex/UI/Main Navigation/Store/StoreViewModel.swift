//
//  StoreViewModel.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/28/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Dependencies
import SwiftUI
import Combine
import StoreKit

struct AlertInfo {

    let title: String
    let message: String?
    var dismissTitle = "Dismiss"

}

extension AlertInfo: Identifiable {

    var id: String { title + (message ?? "") + dismissTitle }

}

/// Main-actor observable state and refresh lifecycle for the store interface.
@MainActor
final class StoreViewModel: ObservableObject {

    @Published var allConsoleProducts: [ProductViewModel] = []
    @Published var allTipProducts: [ProductViewModel] = []
    @Published var alertInfo: AlertInfo?
    @Published var error: ErrorInfo?
    @Published var hasLoadedProducts = false
    @Published var isPurchasing = false

    var hasProducts: Bool {
        !allConsoleProducts.isEmpty
            || !allTipProducts.isEmpty
    }

    @Dependency(\.storeClient) private var storeClient
    @Dependency(\.purchasedProductState) var purchasedProductState
    private let notificationCenter: NotificationCenter
    private var cancellables = Set<AnyCancellable>()
    private var refreshTask: Task<Void, Never>?
    private var refreshGeneration = 0

    init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
        cancellables.insert(notificationCenter
            .publisher(for: StoreClient.purchasedNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.isPurchasing = false
        })
        cancellables.insert(notificationCenter
            .publisher(for: StoreClient.cancelledNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.isPurchasing = false
        })
        cancellables.insert(notificationCenter
            .publisher(for: StoreClient.deferredNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.isPurchasing = false
        })
        cancellables.insert(notificationCenter
            .publisher(for: StoreClient.failedNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.isPurchasing = false
                self?.alertInfo = .init(
                    title: "Unable to purchase",
                    message: "Check your network settings and try again.")
        })
        cancellables.insert(notificationCenter
            .publisher(for: StoreClient.purchasedNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notification in
                debugPrint("Purchase notification received")
                let message: String
                if StoreClient.isTipPurchaseNotification(notification) {
                    message = "Thanks for the tip! ♥️"
                } else {
                    message = "Use \"Choose Game\" on the main screen to select the purchased game(s)."
                }
                self?.alertInfo = .init(title: "Thank You!", message: message)
        })
    }

    deinit {
        refreshTask?.cancel()
    }

    func requestProducts() {
        alertInfo = nil
        error = nil
        refreshTask?.cancel()
        refreshGeneration &+= 1

        let client = storeClient
        let generation = refreshGeneration
        refreshTask = Task { [weak self, client, generation] in
            do {
                let products = try await client.requestProducts()
                try Task.checkCancellation()
                guard let self, self.refreshGeneration == generation else { return }
                self.updateProducts(with: products)
            } catch is CancellationError {
                return
            } catch {
                guard let self, self.refreshGeneration == generation else { return }
                self.handleProductsError(error)
            }
        }
    }

    func purchaseProduct(_ product: ProductViewModel) {
        isPurchasing = true
        storeClient.purchaseProduct(product.product)
    }

    func restorePurchases() {
        storeClient.restorePurchases()
    }

    private func updateProducts(with products: [SKProduct]) {
        var productsByidentifier: [String: SKProduct] = [:]
        products.forEach {
            productsByidentifier[$0.productIdentifier] = $0
        }

        let allConsoleProducts = PokepediaProduct.allConsoleProductsInOrder
            .compactMap { productsByidentifier[$0.productIdentifier] }
            .compactMap { ProductViewModel(product: $0, discountPercent: PokepediaProduct.allBundleDiscounts[$0.productIdentifier], showDescription: true) }
        let allTipProducts = PokepediaProduct.allTipProductsInOrder
            .compactMap { productsByidentifier[$0.productIdentifier] }
            .compactMap { ProductViewModel(product: $0, discountPercent: nil, showDescription: false) }

        hasLoadedProducts = true
        if allConsoleProducts != self.allConsoleProducts {
            self.allConsoleProducts = allConsoleProducts
        }
        if allTipProducts != self.allTipProducts {
            self.allTipProducts = allTipProducts
        }
    }

    private func handleProductsError(_ error: Error?) {
        guard !hasLoadedProducts else { return } // Ignore errors on reload
        debugPrint(String(describing: error))
        alertInfo = .init(
            title: "Failed to fetch products",
            message: "Check your network settings and try again.")
        self.error = .init(error: error)
    }

}
