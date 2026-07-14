import Combine
import Dependencies
import StoreKit
import XCTest
@testable import PikaDex

@MainActor
final class StoreViewModelConcurrencyTests: XCTestCase {

    func testReplacementIgnoresLateNonCooperativeFailure() async {
        let client = ControlledStoreClient()
        let viewModel = makeViewModel(client: client)

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

    func testSuccessfulPublicationOccursOnMainThread() async {
        let client = ControlledStoreClient()
        let viewModel = makeViewModel(client: client)
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
        var viewModel: StoreViewModel? = makeViewModel(client: client)
        weak var weakViewModel = viewModel

        viewModel?.requestProducts()
        await client.waitForRequestCount(1)
        viewModel = nil

        XCTAssertNil(weakViewModel)
        client.completeRequest(at: 0, with: .success([]))
        await Task.yield()
    }

    private func makeViewModel(client: ControlledStoreClient) -> StoreViewModel {
        let purchasedProductState = PurchasedProductState()
        return withDependencies {
            $0.storeClient = client
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

private final class ControlledStoreClient: StoreClientProtocol {
    private let lock = NSLock()
    private var continuations: [CheckedContinuation<[SKProduct], Error>] = []

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
