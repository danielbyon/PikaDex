//
//  StoreClient.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/11/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Dependencies
import Foundation
import StoreKit

typealias ProductIdentifier = String

enum StoreClientError: Error {
    case unableToMakePayments
}

/// Store operations used by the store UI.
///
/// Product loading is asynchronous and cooperatively cancellable. Purchase and
/// restore operations retain StoreKit 1 behavior because their results continue
/// to arrive through transaction notifications.
protocol StoreClientProtocol: AnyObject {
    func requestProducts() async throws -> [SKProduct]
    func purchaseProduct(_ product: SKProduct)
    func restorePurchases()
}

final class StoreClient: NSObject, StoreClientProtocol {

    static let purchasedNotification = Notification.Name("com.danielbyon.pokepedia.StoreClient.purchasedNotification")
    static let transactionUserInfoKey = "transaction"
    static let cancelledNotification = Notification.Name("com.danielbyon.pokepedia.StoreClient.cancelledNotification")
    static let deferredNotification = Notification.Name("com.danielbyon.pokepedia.StoreClient.deferredNotification")
    static let failedNotification = Notification.Name("com.danielbyon.pokepedia.StoreClient.failedNotification")

    private let productIdentifiers: Set<ProductIdentifier>
    private let coordinator: ProductRequestCoordinator
    private let canMakePayments: () -> Bool
    private let observesPaymentQueue: Bool

    convenience init(
        productIdentifiers: Set<ProductIdentifier>,
        canMakePayments: @escaping () -> Bool = { SKPaymentQueue.canMakePayments() },
        makeRequest: @escaping (Set<ProductIdentifier>) -> SKProductsRequest = SKProductsRequest.init(productIdentifiers:)
    ) {
        self.init(
            productIdentifiers: productIdentifiers,
            canMakePayments: canMakePayments,
            observesPaymentQueue: true,
            makeRequestHandle: { StoreKitProductRequest(request: makeRequest($0)) }
        )
    }

    init(
        productIdentifiers: Set<ProductIdentifier>,
        canMakePayments: @escaping () -> Bool,
        observesPaymentQueue: Bool,
        makeRequestHandle: @escaping (Set<ProductIdentifier>) -> ProductRequestHandle
    ) {
        self.productIdentifiers = productIdentifiers
        self.canMakePayments = canMakePayments
        self.observesPaymentQueue = observesPaymentQueue
        self.coordinator = ProductRequestCoordinator(makeRequest: makeRequestHandle)
        super.init()
        coordinator.delegate = self
        if observesPaymentQueue {
            SKPaymentQueue.default().add(self)
        }
    }

    deinit {
        coordinator.shutdown(reason: .ownerReleased)
        if observesPaymentQueue {
            SKPaymentQueue.default().remove(self)
        }
    }

    func requestProducts() async throws -> [SKProduct] {
        try Task.checkCancellation()
        guard canMakePayments() else {
            throw StoreClientError.unableToMakePayments
        }

        let token = UUID()
        coordinator.prepare(token: token)
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                coordinator.register(
                    token: token,
                    productIdentifiers: productIdentifiers,
                    continuation: continuation
                )
            }
        } onCancel: {
            coordinator.cancel(token: token, reason: .taskCancelled)
        }
    }

    func purchaseProduct(_ product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    /// Cancels active product loading and prevents new product requests.
    func shutdown() {
        coordinator.shutdown(reason: .explicitTeardown)
    }

    static func isTipPurchaseNotification(_ notification: Notification) -> Bool {
        guard let transaction = notification.userInfo?[Self.transactionUserInfoKey] as? SKPaymentTransaction,
              let product = PokepediaProduct(rawValue: transaction.payment.productIdentifier) else {
            return false
        }
        return product.isTip
    }
}

// MARK: - SKPaymentTransactionObserver

extension StoreClient: SKPaymentTransactionObserver {

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            let identifier = String(describing: transaction.transactionIdentifier)
            switch transaction.transactionState {
            case .purchased:
                debugPrint("Transaction \(identifier) purchased!")
                NotificationCenter.default.post(name: Self.purchasedNotification, object: self, userInfo: [Self.transactionUserInfoKey: transaction])
            case .failed where (transaction.error as NSError?)?.code == SKError.paymentCancelled.rawValue:
                debugPrint("Transaction \(identifier) cancelled, nothing left to do")
                NotificationCenter.default.post(name: Self.cancelledNotification, object: self, userInfo: [Self.transactionUserInfoKey: transaction])
            case .failed:
                debugPrint("Transaction \(identifier) failed with error \(String(describing: transaction.error))")
                NotificationCenter.default.post(name: Self.failedNotification, object: self, userInfo: [Self.transactionUserInfoKey: transaction])
            case .deferred:
                debugPrint("Transaction \(identifier) in deferred state")
                NotificationCenter.default.post(name: Self.deferredNotification, object: self, userInfo: [Self.transactionUserInfoKey: transaction])
            case .purchasing:
                debugPrint("Transaction \(identifier) in purchasing state")
            case .restored:
                debugPrint("Transaction \(identifier) restored")
                NotificationCenter.default.post(name: Self.purchasedNotification, object: self, userInfo: [Self.transactionUserInfoKey: transaction])
            @unknown default:
                debugPrint("Transaction \(identifier) in unknown state: \(transaction.transactionState)")
            }

            if transaction.transactionState != .purchasing && transaction.transactionState != .deferred {
                queue.finishTransaction(transaction)
            }
        }
    }

    #if !targetEnvironment(macCatalyst)
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        true
    }
    #endif
}

// MARK: - SKProductsRequestDelegate

extension StoreClient: SKProductsRequestDelegate {

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if !response.invalidProductIdentifiers.isEmpty {
            debugPrint("Invalid product identifiers returned: \(response.invalidProductIdentifiers)")
        }
        coordinator.succeed(request: request, products: response.products)
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
        guard let productsRequest = request as? SKProductsRequest else { return }
        coordinator.fail(request: productsRequest, error: error)
    }
}

/// Serialized owner for the StoreKit request and its checked continuation.
///
/// All state transitions execute on `executor`. Active state is detached before
/// cancelling a request or resuming its continuation, which makes re-entrant or
/// duplicate delegate callbacks harmless.
final class ProductRequestCoordinator {

    enum TerminalReason: Equatable {
        case taskCancelled
        case replaced
        case requestFailed
        case explicitTeardown
        case ownerReleased
    }

    private struct ActiveRequest {
        let token: UUID
        let generation: UInt64
        let request: ProductRequestHandle
        let continuation: CheckedContinuation<[SKProduct], Error>
    }

    private let executor = DispatchQueue(label: "com.danielbyon.pokedex.store-products")
    private let executorKey = DispatchSpecificKey<UInt8>()
    private let makeRequest: (Set<ProductIdentifier>) -> ProductRequestHandle
    private var activeRequest: ActiveRequest?
    private var pendingRegistrationTokens: Set<UUID> = []
    private var cancelledBeforeRegistration: Set<UUID> = []
    private var generation: UInt64 = 0
    private var isShutDown = false

    weak var delegate: SKProductsRequestDelegate?
    private var lastTerminalReason: TerminalReason?

    init(makeRequest: @escaping (Set<ProductIdentifier>) -> ProductRequestHandle) {
        self.makeRequest = makeRequest
        executor.setSpecific(key: executorKey, value: 1)
    }

    func prepare(token: UUID) {
        executeSynchronously {
            pendingRegistrationTokens.insert(token)
        }
    }

    func register(
        token: UUID,
        productIdentifiers: Set<ProductIdentifier>,
        continuation: CheckedContinuation<[SKProduct], Error>
    ) {
        executeSynchronously {
            guard pendingRegistrationTokens.remove(token) != nil else {
                continuation.resume(throwing: CancellationError())
                return
            }
            let wasCancelledBeforeRegistration = cancelledBeforeRegistration.remove(token) != nil
            if isShutDown || wasCancelledBeforeRegistration {
                continuation.resume(throwing: CancellationError())
                return
            }

            if let replaced = detachActive(reason: .replaced) {
                replaced.request.cancel()
                replaced.continuation.resume(throwing: CancellationError())
            }

            let request = makeRequest(productIdentifiers)
            request.delegate = delegate
            generation &+= 1
            activeRequest = ActiveRequest(
                token: token,
                generation: generation,
                request: request,
                continuation: continuation
            )
            request.start()
        }
    }

    func succeed(request: SKProductsRequest, products: [SKProduct]) {
        executeSynchronously {
            guard let active = activeRequest, active.request.matches(request) else { return }
            activeRequest = nil
            active.continuation.resume(returning: products)
        }
    }

    func fail(request: SKProductsRequest, error: Error) {
        executeSynchronously {
            guard let active = activeRequest, active.request.matches(request) else { return }
            activeRequest = nil
            lastTerminalReason = .requestFailed
            active.continuation.resume(throwing: error)
        }
    }

    func succeed(requestHandle: ProductRequestHandle, products: [SKProduct]) {
        complete(requestHandle: requestHandle, result: .success(products))
    }

    func fail(requestHandle: ProductRequestHandle, error: Error) {
        complete(requestHandle: requestHandle, result: .failure(error))
    }

    func cancel(token: UUID, reason: TerminalReason) {
        executeSynchronously {
            guard activeRequest?.token == token else {
                if pendingRegistrationTokens.contains(token) {
                    cancelledBeforeRegistration.insert(token)
                }
                return
            }
            guard let active = detachActive(reason: reason) else { return }
            active.request.cancel()
            active.continuation.resume(throwing: CancellationError())
        }
    }

    func shutdown(reason: TerminalReason) {
        executeSynchronously {
            guard !isShutDown else { return }
            isShutDown = true
            guard let active = detachActive(reason: reason) else { return }
            active.request.cancel()
            active.continuation.resume(throwing: CancellationError())
        }
    }

    /// Returns the latest non-success terminal transition on the coordinator's
    /// serialized executor.
    func currentTerminalReason() -> TerminalReason? {
        executeSynchronously { lastTerminalReason }
    }

    private func detachActive(reason: TerminalReason) -> ActiveRequest? {
        guard let active = activeRequest else { return nil }
        activeRequest = nil
        lastTerminalReason = reason
        return active
    }

    private func complete(
        requestHandle: ProductRequestHandle,
        result: Result<[SKProduct], Error>
    ) {
        executeSynchronously {
            guard let active = activeRequest, active.request === requestHandle else { return }
            activeRequest = nil
            if case .failure = result {
                lastTerminalReason = .requestFailed
            }
            active.continuation.resume(with: result)
        }
    }

    private func executeSynchronously<T>(_ operation: () -> T) -> T {
        if DispatchQueue.getSpecific(key: executorKey) != nil {
            return operation()
        }
        return executor.sync(execute: operation)
    }
}

/// Minimal request surface owned by the serialized product-request coordinator.
/// StoreKit requests are wrapped so tests never need to subclass framework
/// request objects, which is unsupported by StoreKit.
protocol ProductRequestHandle: AnyObject {
    var delegate: SKProductsRequestDelegate? { get set }
    func start()
    func cancel()
    func matches(_ request: SKProductsRequest) -> Bool
}

private final class StoreKitProductRequest: ProductRequestHandle {
    private let request: SKProductsRequest

    var delegate: SKProductsRequestDelegate? {
        get { request.delegate as? SKProductsRequestDelegate }
        set { request.delegate = newValue }
    }

    init(request: SKProductsRequest) {
        self.request = request
    }

    func start() {
        request.start()
    }

    func cancel() {
        request.cancel()
    }

    func matches(_ request: SKProductsRequest) -> Bool {
        self.request === request
    }
}

private enum StoreClientKey: DependencyKey {
    static var liveValue: any StoreClientProtocol {
        fatalError("StoreClient must be supplied by the application composition root.")
    }

    static var testValue: any StoreClientProtocol {
        fatalError("Tests must inject an isolated StoreClientProtocol implementation.")
    }
}

extension DependencyValues {
    var storeClient: any StoreClientProtocol {
        get { self[StoreClientKey.self] }
        set { self[StoreClientKey.self] = newValue }
    }
}
