//
//  StoreViewModel.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/28/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

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

    private var storeClient = PokepediaProduct.store
    private var purchasedProductState = Dependencies.purchasedProductState
    private var cancellables = Set<AnyCancellable>()
    private var observers = [NSObjectProtocol]()

    init() {
        cancellables.insert(NotificationCenter.default
            .publisher(for: StoreClient.purchasedNotification)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                self.isPurchasing = false
        })
        cancellables.insert(NotificationCenter.default
            .publisher(for: StoreClient.cancelledNotification)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                self.isPurchasing = false
        })
        cancellables.insert(NotificationCenter.default
            .publisher(for: StoreClient.deferredNotification)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                self.isPurchasing = false
        })
        cancellables.insert(NotificationCenter.default
            .publisher(for: StoreClient.failedNotification)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                self.isPurchasing = false
                self.alertInfo = .init(
                    title: "Unable to purchase",
                    message: "Check your network settings and try again.")
        })
        cancellables.insert(NotificationCenter.default
            .publisher(for: StoreClient.purchasedNotification)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] notification in
                DispatchQueue.main.async {
                debugPrint("Purchase notification received")
                    let message: String
                    if StoreClient.isTipPurchaseNotification(notification) {
                        message = "Thanks for the tip! ♥️"
                    } else {
                        message = "Use \"Choose Game\" on the main screen to select the purchased game(s)."
                    }
                    self.alertInfo = .init(
                        title: "Thank You!",
                        message: message)
                }
        })
    }

    func requestProducts() {
        alertInfo = nil
        error = nil
        storeClient.requestProducts { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let products):
                self.updateProducts(with: products)
            case .failure(let error):
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

        DispatchQueue.main.async {
            self.hasLoadedProducts = true
            if allConsoleProducts != self.allConsoleProducts {
                self.allConsoleProducts = allConsoleProducts
            }
            if allTipProducts != self.allTipProducts {
                self.allTipProducts = allTipProducts
            }
        }
    }

    private func handleProductsError(_ error: Error?) {
        guard !hasLoadedProducts else { return } // Ignore errors on reload
        debugPrint(String(describing: error))
        DispatchQueue.main.async {
            self.alertInfo = .init(
                title: "Failed to fetch products",
                message: "Check your network settings and try again.")
            self.error = .init(error: error)
        }
    }

}
