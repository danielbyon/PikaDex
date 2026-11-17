import Combine
import Dependencies
import StoreKit
import XCTest
@testable import PikaDex

@MainActor
final class StoreViewModelConcurrencyTests: XCTestCase {

    func testReplacementIgnoresLateNonCooperativeFailure() async {
        let client = ControlledStoreClient()
        let purchaseHarness = PurchasedProductStateTestHarness()
        defer { purchaseHarness.cleanUp() }
        let viewModel = makeViewModel(client: client, purchasedProductState: purchaseHarness.state)

        viewModel.requestProducts()
        await client.waitForRequestCount(1)
        viewModel.requestProducts()
        await client.waitForRequestCount(2)

        client.completeRequest(at: 0, with: .failure(ControlledError.failure))
        await Task.yield()
        XCTAssertNil(viewModel.error)

        client.completeRequest(at: 1, with: .success([]))
        await waitUntil { viewModel.hasLoadedProducts }
        XCTAssertNil(viewModel.error)
    }

    func testReplacementIgnoresLateNonCooperativeSuccess() async {
        let client = ControlledStoreClient()
        let purchaseHarness = PurchasedProductStateTestHarness()
        defer { purchaseHarness.cleanUp() }
        let viewModel = makeViewModel(client: client, purchasedProductState: purchaseHarness.state)

        viewModel.requestProducts()
        await client.waitForRequestCount(1)
        viewModel.requestProducts()
        await client.waitForRequestCount(2)

        client.completeRequest(at: 0, with: .success([]))
        await Task.yield()
        XCTAssertFalse(viewModel.hasLoadedProducts)

        client.completeRequest(at: 1, with: .failure(ControlledError.failure))
        await waitUntil { viewModel.error != nil }
        await Task.yield()
        XCTAssertFalse(viewModel.hasLoadedProducts)
    }

    func testSuccessfulPublicationOccursOnMainThread() async {
        let client = ControlledStoreClient()
        let purchaseHarness = PurchasedProductStateTestHarness()
        defer { purchaseHarness.cleanUp() }
        let viewModel = makeViewModel(client: client, purchasedProductState: purchaseHarness.state)
        let published = expectation(description: "products published")
        var cancellable: AnyCancellable?
        cancellable = viewModel.$hasLoadedProducts
            .dropFirst()
            .sink { hasLoadedProducts in
                guard hasLoadedProducts else { return }
                XCTAssertTrue(Thread.isMainThread)
                published.fulfill()
            }

        viewModel.requestProducts()
        await client.waitForRequestCount(1)
        client.completeRequest(at: 0, with: .success([]))

        await fulfillment(of: [published], timeout: 1)
        withExtendedLifetime(cancellable) { }
    }

    func testRefreshTaskDoesNotRetainViewModel() async {
        let client = ControlledStoreClient()
        let purchaseHarness = PurchasedProductStateTestHarness()
        defer { purchaseHarness.cleanUp() }
        var viewModel: StoreViewModel? = makeViewModel(
            client: client,
            purchasedProductState: purchaseHarness.state
        )
        weak var weakViewModel = viewModel

        viewModel?.requestProducts()
        await client.waitForRequestCount(1)
        viewModel = nil

        XCTAssertNil(weakViewModel)
        client.completeRequest(at: 0, with: .success([]))
        await Task.yield()
    }

    private func makeViewModel(
        client: ControlledStoreClient,
        purchasedProductState: PurchasedProductState
    ) -> StoreViewModel {
        return withDependencies {
            $0.storeClient = StoreClientReference(client)
            $0.purchasedProductState = purchasedProductState
        } operation: {
            StoreViewModel(notificationCenter: NotificationCenter())
        }
    }

    private func waitUntil(
        _ condition: @escaping @MainActor () -> Bool
    ) async {
        for _ in 0..<1_000 {
            if condition() { return }
            await Task.yield()
        }
        XCTFail("Condition was not satisfied")
    }
}

private enum ControlledError: Error {
    case failure
}

/// Its lock protects every stored continuation used by concurrent test tasks.
private final class ControlledStoreClient: StoreClientProtocol, @unchecked Sendable {
    private let lock = NSLock()
    private var continuations: [CheckedContinuation<[SKProduct], Error>] = []

    @MainActor
    func requestProducts() async throws -> [SKProduct] {
        try await withCheckedThrowingContinuation { continuation in
            lock.withLock { continuations.append(continuation) }
        }
    }

    func purchaseProduct(_ product: SKProduct) { }

    func restorePurchases() { }

    func waitForRequestCount(_ count: Int) async {
        while lock.withLock({ continuations.count }) < count {
            await Task.yield()
        }
    }

    func completeRequest(at index: Int, with result: Result<[SKProduct], Error>) {
        let continuation = lock.withLock { continuations[index] }
        continuation.resume(with: result)
    }
}
