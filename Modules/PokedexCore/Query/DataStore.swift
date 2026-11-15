//
//  DataStore.swift
//  Pokedex
//
//  Created by Daniel Byon on 10/19/21.
//  Copyright © 2021 Daniel Byon. All rights reserved.
//

import Dependencies
import Foundation
import CoreData
import SwiftUI

internal enum DataStoreIdentity: Equatable {
    case context(ObjectIdentifier)
    case unavailable(ObjectIdentifier)
}

internal enum ObservedQueryError: Error {
    case unavailableStore(Error)
    case requestConstruction(Error)
    case fetch(Error)
    case observationRequiresMainQueueContext

    var queryFailure: QueryFailure {
        switch self {
        case .unavailableStore:
            return .unavailableStore
        case .requestConstruction(let error):
            guard let queryError = error as? QueryError else {
                return .requestConstruction
            }
            switch queryError {
            case .missingFilter:
                return .missingFilter
            case .unsupportedFilter:
                return .unsupportedFilter
            }
        case .fetch, .observationRequiresMainQueueContext:
            return .fetch
        }
    }

    var underlyingError: Error {
        switch self {
        case .unavailableStore(let error),
             .requestConstruction(let error),
             .fetch(let error):
            return error
        case .observationRequiresMainQueueContext:
            return self
        }
    }
}

internal struct QueryObservation<ResultType: NSManagedObject> {
    let controller: NSFetchedResultsController<ResultType>
    let results: NSArray
}

/// A Core Data store that runs its operations on the managed context's queue.
///
/// The unchecked conformance relies on this queue confinement. Filters and
/// persistence models are used during each synchronous call and are not retained
/// by the store. Callers must not access shared mutable reference state through
/// those values while a call is running.
///
/// Calls from the main thread use a reentrant fast path for a main-queue context.
/// Other calls use `performAndWait`.
/// One-shot fetches convert managed objects into `Queryable` values before
/// returning them. Observed results retain managed objects for lazy conversion
/// and require a main-queue context, which `Query` reads on the main actor.
public final class DataStore: NSObject, ObservableObject, @unchecked Sendable {

    internal typealias ObservationFetch = (_ performFetch: () throws -> Void) throws -> Void

    /// Compatibility access to the cached production catalog.
    ///
    /// New composition code should use the ready values returned by
    /// `PersistenceBootstrap.production()`. This accessor resolves the cached
    /// bootstrap once and never performs bootstrap work during fetches.
    public static let pokedex: DataStore = {
        do {
            return try PersistenceBootstrap.production().pokedex
        } catch {
            return DataStore(error: error)
        }
    }()

    /// Compatibility access to the cached production user-data store.
    public static let userData: DataStore = {
        do {
            return try PersistenceBootstrap.production().userData
        } catch {
            return DataStore(error: error)
        }
    }()

    internal let contextResult: Result<NSManagedObjectContext, Error>
    private let observationFetch: ObservationFetch?

    internal var identity: DataStoreIdentity {
        switch contextResult {
        case .success(let context):
            return .context(ObjectIdentifier(context))
        case .failure:
            return .unavailable(ObjectIdentifier(self))
        }
    }

    /// Creates a data store from a container whose persistent stores have
    /// already loaded successfully.
    public init(container: NSPersistentContainer) {
        self.contextResult = .success(container.viewContext)
        self.observationFetch = nil
    }

    internal init(error: Error) {
        self.contextResult = .failure(error)
        self.observationFetch = nil
    }

    internal init(
        context: NSManagedObjectContext,
        observationFetch: ObservationFetch? = nil
    ) {
        self.contextResult = .success(context)
        self.observationFetch = observationFetch
    }

    public func fetch<T: Queryable>(_: T.Type, filter: T.Filter) throws -> [T] {
        let viewContext = try contextResult.get()
        return try performSynchronously(on: viewContext) {
            let request = try filter.makeFetchRequest()
            return try viewContext.fetch(request).map(T.init)
        }
    }

    public func save<T: Persistable>(_ object: T) throws {
        let viewContext = try contextResult.get()
        try performSynchronously(on: viewContext) {
            let _ = object.makeModelObject(context: viewContext)
            try viewContext.save()
        }
    }

    public func remove<T: Queryable>(_: T.Type, filter: T.Filter) throws {
        let viewContext = try contextResult.get()
        try performSynchronously(on: viewContext) {
            let request = try filter.makeFetchRequest()
            let objects = try viewContext.fetch(request)
            objects.forEach {
                viewContext.delete($0)
            }
            try viewContext.save()
        }
    }

    /// Builds observations for the main-queue context used by SwiftUI.
    ///
    /// `QueryResults` reads fetched managed objects lazily, so a background
    /// context cannot safely produce rows for main-actor access.
    internal func makeObservation<Filter: QueryFilter>(
        for filter: Filter,
        delegate: NSFetchedResultsControllerDelegate
    ) throws -> QueryObservation<Filter.ResultType> {
        let viewContext: NSManagedObjectContext
        do {
            viewContext = try contextResult.get()
        } catch {
            throw ObservedQueryError.unavailableStore(error)
        }

        return try performSynchronously(on: viewContext) {
            guard viewContext.concurrencyType == .mainQueueConcurrencyType else {
                throw ObservedQueryError.observationRequiresMainQueueContext
            }

            let request: NSFetchRequest<Filter.ResultType>
            do {
                request = try filter.makeFetchRequest()
            } catch {
                throw ObservedQueryError.requestConstruction(error)
            }

            configureForObservation(request)
            let controller = NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: viewContext,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            controller.delegate = delegate

            do {
                if let observationFetch = self.observationFetch {
                    try observationFetch {
                        try controller.performFetch()
                    }
                } else {
                    try controller.performFetch()
                }
            } catch {
                controller.delegate = nil
                throw ObservedQueryError.fetch(error)
            }

            return QueryObservation(
                controller: controller,
                results: (controller.fetchedObjects as NSArray?) ?? NSArray()
            )
        }
    }

    internal static func detach<ResultType>(
        _ controller: NSFetchedResultsController<ResultType>
    ) where ResultType: NSFetchRequestResult {
        let context = controller.managedObjectContext
        do {
            try performSynchronously(on: context) {
                controller.delegate = nil
            }
        } catch {
            assertionFailure("Detaching a fetched-results controller unexpectedly failed: \(error)")
        }
    }

}

private func configureForObservation<ResultType>(
    _ request: NSFetchRequest<ResultType>
) where ResultType: NSFetchRequestResult {
    if request.fetchBatchSize == 0 {
        request.fetchBatchSize = DatabaseConstants.fetchBatchSize
    }

    // Core Data exposes `returnsObjectsAsFaults` as a Boolean rather than an
    // optional setting. The current filter inventory contains explicit `false`
    // values and no explicit `true` override, so `true` is the unset value for
    // the observed-query path and receives the existing observation default.
    if request.returnsObjectsAsFaults {
        request.returnsObjectsAsFaults = false
    }
}

private func performSynchronously<T>(
    on context: NSManagedObjectContext,
    _ operation: @escaping () throws -> T
) throws -> T {
    if context.concurrencyType == .mainQueueConcurrencyType && Thread.isMainThread {
        return try operation()
    }

    let queueOperation = ContextQueueOperation(operation)
    return try context.performAndWait { try queueOperation.run() }
}

/// Carries a synchronous operation to its managed object's context queue.
///
/// `performAndWait` finishes before the caller returns. Callers must not access
/// captured mutable state from another thread while the operation runs. This
/// carrier must not outlive the synchronous call or be used asynchronously.
private final class ContextQueueOperation<Output>: @unchecked Sendable {
    let run: () throws -> Output

    init(_ run: @escaping () throws -> Output) {
        self.run = run
    }
}

private enum PreviewPersistenceStores {
    /// The cached contexts are accessed through DataStore's queue confinement.
    nonisolated(unsafe) static let result: Result<PersistenceStores, Error> = Result {
        try PersistenceBootstrap.preview()
    }

    static func dataStore(_ keyPath: KeyPath<PersistenceStores, DataStore>) -> DataStore {
        do {
            return try result.get()[keyPath: keyPath]
        } catch {
            return DataStore(error: error)
        }
    }
}

private extension DataStore {
    static func unconfiguredTestStore(named name: String) -> DataStore {
        DataStore(error: PersistenceBootstrapError(
            stage: .testConfiguration,
            modelName: name,
            recoveryContext: .injectTestStore
        ))
    }
}

private enum PokedexDataStoreKey: DependencyKey {
    static let liveValue: DataStore = .pokedex
    static let previewValue = PreviewPersistenceStores.dataStore(\.pokedex)
    static let testValue = DataStore.unconfiguredTestStore(named: "Pokedex")
}

private enum UserDataDataStoreKey: DependencyKey {
    static let liveValue: DataStore = .userData
    static let previewValue = PreviewPersistenceStores.dataStore(\.userData)
    static let testValue = DataStore.unconfiguredTestStore(named: "UserData")
}

public extension DependencyValues {

    var pokedexDataStore: DataStore {
        get { self[PokedexDataStoreKey.self] }
        set { self[PokedexDataStoreKey.self] = newValue }
    }

    var userDataDataStore: DataStore {
        get { self[UserDataDataStoreKey.self] }
        set { self[UserDataDataStoreKey.self] = newValue }
    }

}
