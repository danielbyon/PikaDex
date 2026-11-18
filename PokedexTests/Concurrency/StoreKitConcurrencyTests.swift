import StoreKit
import XCTest
@testable import PikaDex

@MainActor
final class StoreKitConcurrencyTests: XCTestCase {

    func testSuccessfulRequestCompletesOnceAndIgnoresLateCallbacks() async throws {
        let factory = RequestFactory()
        let coordinator = ProductRequestCoordinator(makeRequest: factory.makeRequest)
        let token = UUID()
        let task = coordinatorTask(coordinator, token: token)
        let request = await factory.request(at: 0)

        coordinator.succeed(request: request.storeKitRequest, products: [])
        let products = try await task.value
        XCTAssertEqual(products.count, 0)

        coordinator.fail(request: request.storeKitRequest, error: TestError.failure)
        XCTAssertNil(coordinator.currentTerminalReason())
    }

    func testFailurePreservesStoreKitErrorAndIgnoresDuplicateCompletion() async {
        let factory = RequestFactory()
        let coordinator = ProductRequestCoordinator(makeRequest: factory.makeRequest)
        let task = coordinatorTask(coordinator, token: UUID())
        let request = await factory.request(at: 0)

        coordinator.fail(request: request.storeKitRequest, error: TestError.failure)
        await assertThrows(TestError.self, from: task)
        XCTAssertEqual(coordinator.currentTerminalReason(), .requestFailed)

        coordinator.succeed(request: request.storeKitRequest, products: [])
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

        coordinator.fail(request: firstRequest.storeKitRequest, error: TestError.failure)
        XCTAssertEqual(coordinator.currentTerminalReason(), .replaced)

        coordinator.succeed(request: secondRequest.storeKitRequest, products: [])
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

    @MainActor
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

    @MainActor
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

    @MainActor
    func testCancellationRacingReplacementLeavesSuccessorUnaffectedByStaleCallback() async {
        let factory = RequestFactory()
        let client = StoreClient(
            productIdentifiers: ["test.product"],
            canMakePayments: { true },
            observesPaymentQueue: false,
            makeRequestHandle: factory.makeRequest
        )
        let firstTask = Task { try await client.requestProducts() }
        let firstRequest = await factory.request(at: 0)
        let gate = TwoPartyGate()
        let cancellationTask = Task.detached {
            await gate.waitForBothParticipants()
            firstTask.cancel()
        }
        let successorTask = Task {
            await gate.waitForBothParticipants()
            _ = try await client.requestProducts()
        }

        await cancellationTask.value
        let successorRequest = await factory.request(at: 1)
        await assertCancellation(from: firstTask)

        XCTAssertEqual(firstRequest.cancelCount, 1)
        XCTAssertEqual(successorRequest.cancelCount, 0)
        let firstTerminalReason = client.coordinator.currentTerminalReason()
        XCTAssertTrue(firstTerminalReason == .taskCancelled || firstTerminalReason == .replaced)

        firstRequest.reportFailure(TestError.stale)
        successorRequest.reportFailure(TestError.active)

        do {
            _ = try await successorTask.value
            XCTFail("Expected the successor request's own failure")
        } catch let error as TestError {
            XCTAssertEqual(error, .active)
        } catch {
            XCTFail("Expected the successor error, received \(error)")
        }
        XCTAssertEqual(firstRequest.cancelCount, 1)
        XCTAssertEqual(successorRequest.cancelCount, 0)
    }

    func testReleasingStoreClientLifetimeCancelsItsActiveRequest() async throws {
        let factory = RequestFactory()
        let client = StoreClient(
            productIdentifiers: ["test.product"],
            canMakePayments: { true },
            observesPaymentQueue: false,
            makeRequestHandle: factory.makeRequest
        )
        var lifetime: StoreClientRequestLifetime? = StoreClientRequestLifetime(coordinator: client.coordinator)
        weak var weakLifetime = lifetime
        let task = Task { try await client.requestProducts() }
        let request = await factory.request(at: 0)

        lifetime = nil

        guard weakLifetime == nil else {
            XCTFail("The app-owned request lifetime must release during owner teardown")
            return
        }
        await assertCancellation(from: task)
        XCTAssertEqual(request.cancelCount, 1)
        XCTAssertEqual(client.coordinator.currentTerminalReason(), .ownerReleased)

        request.reportFailure(TestError.failure)
        client.shutdown()
        XCTAssertEqual(request.cancelCount, 1)
        XCTAssertEqual(client.coordinator.currentTerminalReason(), .ownerReleased)
    }

    @MainActor
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

private enum TestError: Error, Equatable {
    case failure
    case stale
    case active
}

/// The lock protects mutable state; the StoreKit request is a stable identity token.
private final class TestProductsRequest: ProductRequestHandle, @unchecked Sendable {
    private let lock = NSLock()
    private var cancellations = 0
    private var starts = 0
    private var startWaiters: [CheckedContinuation<Void, Never>] = []
    private weak var storedDelegate: SKProductsRequestDelegate?

    let storeKitRequest: SKProductsRequest

    init(productIdentifiers: Set<ProductIdentifier>) {
        storeKitRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
    }

    var cancelCount: Int {
        lock.withLock { cancellations }
    }

    var delegate: SKProductsRequestDelegate? {
        get { lock.withLock { storedDelegate } }
        set { lock.withLock { storedDelegate = newValue } }
    }

    func start() {
        let waiters = lock.withLock { () -> [CheckedContinuation<Void, Never>] in
            starts += 1
            let waiters = startWaiters
            startWaiters.removeAll()
            return waiters
        }
        waiters.forEach { $0.resume() }
    }

    func cancel() {
        lock.withLock { cancellations += 1 }
    }

    func matches(_ request: SKProductsRequest) -> Bool {
        storeKitRequest === request
    }

    func reportFailure(_ error: Error) {
        delegate?.request?(storeKitRequest, didFailWithError: error)
    }

    func waitUntilStarted() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            let alreadyStarted = lock.withLock {
                guard starts == 0 else { return true }
                startWaiters.append(continuation)
                return false
            }
            if alreadyStarted {
                continuation.resume()
            }
        }
    }
}

/// The lock protects requests and waiters shared by test and coordinator tasks.
private final class RequestFactory: @unchecked Sendable {
    private let lock = NSLock()
    private var requests: [TestProductsRequest] = []
    private var requestWaiters: [Int: [CheckedContinuation<TestProductsRequest, Never>]] = [:]

    var requestCount: Int {
        lock.withLock { requests.count }
    }

    func makeRequest(productIdentifiers: Set<ProductIdentifier>) -> ProductRequestHandle {
        let request = TestProductsRequest(productIdentifiers: productIdentifiers)
        let waiters = lock.withLock { () -> [CheckedContinuation<TestProductsRequest, Never>] in
            requests.append(request)
            return requestWaiters.removeValue(forKey: requests.count - 1) ?? []
        }
        waiters.forEach { $0.resume(returning: request) }
        return request
    }

    func request(at index: Int) async -> TestProductsRequest {
        let request: TestProductsRequest = await withCheckedContinuation { continuation in
            let existingRequest = lock.withLock { () -> TestProductsRequest? in
                guard requests.indices.contains(index) else {
                    requestWaiters[index, default: []].append(continuation)
                    return nil
                }
                return requests[index]
            }
            if let existingRequest {
                continuation.resume(returning: existingRequest)
            }
        }
        await request.waitUntilStarted()
        return request
    }
}

private actor TwoPartyGate {
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func waitForBothParticipants() async {
        await withCheckedContinuation { continuation in
            waiters.append(continuation)
            guard waiters.count == 2 else { return }
            let ready = waiters
            waiters.removeAll()
            ready.forEach { $0.resume() }
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
