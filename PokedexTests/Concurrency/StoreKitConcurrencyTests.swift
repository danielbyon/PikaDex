import StoreKit
import XCTest
@testable import PikaDex

final class StoreKitConcurrencyTests: XCTestCase {

    func testSuccessfulRequestCompletesOnceAndIgnoresLateCallbacks() async throws {
        let factory = RequestFactory()
        let coordinator = ProductRequestCoordinator(makeRequest: factory.makeRequest)
        let token = UUID()
        let task = coordinatorTask(coordinator, token: token)
        let request = await factory.request(at: 0)

        coordinator.succeed(requestHandle: request, products: [])
        let products = try await task.value
        XCTAssertEqual(products.count, 0)

        coordinator.fail(requestHandle: request, error: TestError.failure)
        XCTAssertNil(coordinator.currentTerminalReason())
    }

    func testFailurePreservesStoreKitErrorAndIgnoresDuplicateCompletion() async {
        let factory = RequestFactory()
        let coordinator = ProductRequestCoordinator(makeRequest: factory.makeRequest)
        let task = coordinatorTask(coordinator, token: UUID())
        let request = await factory.request(at: 0)

        coordinator.fail(requestHandle: request, error: TestError.failure)
        await assertThrows(TestError.self, from: task)
        XCTAssertEqual(coordinator.currentTerminalReason(), .requestFailed)

        coordinator.succeed(requestHandle: request, products: [])
    }

    func testReplacementCancelsOnlyTheReplacedRequest() async throws {
        let factory = RequestFactory()
        let coordinator = ProductRequestCoordinator(makeRequest: factory.makeRequest)
        let firstTask = coordinatorTask(coordinator, token: UUID())
        let firstRequest = await factory.request(at: 0)
        let secondTask = coordinatorTask(coordinator, token: UUID())
        let secondRequest = await factory.request(at: 1)

        await assertCancellation(from: firstTask)
        XCTAssertEqual(firstRequest.cancelCount, 1)
        XCTAssertEqual(secondRequest.cancelCount, 0)
        XCTAssertEqual(coordinator.currentTerminalReason(), .replaced)

        coordinator.succeed(requestHandle: secondRequest, products: [])
        let products = try await secondTask.value
        XCTAssertEqual(products.count, 0)
    }

    func testCancellationBeforeRegistrationCompletesWithoutStartingARequest() async {
        let factory = RequestFactory()
        let coordinator = ProductRequestCoordinator(makeRequest: factory.makeRequest)
        let token = UUID()

        coordinator.prepare(token: token)
        coordinator.cancel(token: token, reason: .taskCancelled)
        let task = coordinatorTask(coordinator, token: token)

        await assertCancellation(from: task)
        XCTAssertEqual(factory.requestCount, 0)
    }

    func testExplicitTeardownAndOwnerReleaseHaveDistinctTerminalReasons() async {
        for reason in [
            ProductRequestCoordinator.TerminalReason.explicitTeardown,
            .ownerReleased
        ] {
            let factory = RequestFactory()
            let coordinator = ProductRequestCoordinator(makeRequest: factory.makeRequest)
            let task = coordinatorTask(coordinator, token: UUID())
            let request = await factory.request(at: 0)

            coordinator.shutdown(reason: reason)

            await assertCancellation(from: task)
            XCTAssertEqual(request.cancelCount, 1)
            XCTAssertEqual(coordinator.currentTerminalReason(), reason)
            coordinator.shutdown(reason: reason)
            XCTAssertEqual(request.cancelCount, 1)
        }
    }

    func testCancellingSwiftTaskCancelsUnderlyingStoreKitRequestOnce() async {
        let factory = RequestFactory()
        let client = StoreClient(
            productIdentifiers: ["test.product"],
            canMakePayments: { true },
            observesPaymentQueue: false,
            makeRequestHandle: factory.makeRequest
        )
        let task = Task { try await client.requestProducts() }
        let request = await factory.request(at: 0)

        task.cancel()

        await assertCancellation(from: task)
        XCTAssertEqual(request.cancelCount, 1)
        client.shutdown()
        XCTAssertEqual(request.cancelCount, 1)
    }

    func testStoreClientExplicitShutdownResumesActiveRequest() async {
        let factory = RequestFactory()
        let client = StoreClient(
            productIdentifiers: ["test.product"],
            canMakePayments: { true },
            observesPaymentQueue: false,
            makeRequestHandle: factory.makeRequest
        )
        let task = Task { try await client.requestProducts() }
        let request = await factory.request(at: 0)

        client.shutdown()

        await assertCancellation(from: task)
        XCTAssertEqual(request.cancelCount, 1)
    }

    func testPaymentsDisabledFailsWithoutCreatingRequest() async {
        let factory = RequestFactory()
        let client = StoreClient(
            productIdentifiers: ["test.product"],
            canMakePayments: { false },
            observesPaymentQueue: false,
            makeRequestHandle: factory.makeRequest
        )

        do {
            _ = try await client.requestProducts()
            XCTFail("Expected payments-disabled failure")
        } catch StoreClientError.unableToMakePayments {
            XCTAssertEqual(factory.requestCount, 0)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    private func coordinatorTask(
        _ coordinator: ProductRequestCoordinator,
        token: UUID
    ) -> Task<[SKProduct], Error> {
        Task {
            try await withCheckedThrowingContinuation { continuation in
                coordinator.prepare(token: token)
                coordinator.register(
                    token: token,
                    productIdentifiers: ["test.product"],
                    continuation: continuation
                )
            }
        }
    }

    private func assertCancellation(from task: Task<[SKProduct], Error>) async {
        do {
            _ = try await task.value
            XCTFail("Expected CancellationError")
        } catch is CancellationError {
            // Expected.
        } catch {
            XCTFail("Expected CancellationError, received \(error)")
        }
    }

    private func assertThrows<E: Error>(_: E.Type, from task: Task<[SKProduct], Error>) async {
        do {
            _ = try await task.value
            XCTFail("Expected request failure")
        } catch is E {
            // Expected.
        } catch {
            XCTFail("Expected \(E.self), received \(error)")
        }
    }
}

private enum TestError: Error {
    case failure
}

private final class TestProductsRequest: ProductRequestHandle {
    private let lock = NSLock()
    private var cancellations = 0
    private var starts = 0

    var cancelCount: Int {
        lock.withLock { cancellations }
    }

    var startCount: Int {
        lock.withLock { starts }
    }

    var delegate: SKProductsRequestDelegate?

    func start() {
        lock.withLock { starts += 1 }
    }

    func cancel() {
        lock.withLock { cancellations += 1 }
    }

    func matches(_ request: SKProductsRequest) -> Bool { false }
}

private final class RequestFactory {
    private let lock = NSLock()
    private var requests: [TestProductsRequest] = []

    var requestCount: Int {
        lock.withLock { requests.count }
    }

    func makeRequest(productIdentifiers: Set<ProductIdentifier>) -> ProductRequestHandle {
        let request = TestProductsRequest()
        lock.withLock { requests.append(request) }
        return request
    }

    func request(at index: Int) async -> TestProductsRequest {
        while true {
            if let request = lock.withLock({ requests.indices.contains(index) ? requests[index] : nil }) {
                return request
            }
            await Task.yield()
        }
    }
}

extension NSLock {
    func withLock<T>(_ operation: () -> T) -> T {
        lock()
        defer { unlock() }
        return operation()
    }
}
