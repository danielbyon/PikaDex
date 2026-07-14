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
        case .fetch:
            return .fetch
        }
    }

    var underlyingError: Error {
        switch self {
        case .unavailableStore(let error),
             .requestConstruction(let error),
             .fetch(let error):
            return error
        }
    }
}

internal struct QueryObservation<ResultType: NSManagedObject> {
    let controller: NSFetchedResultsController<ResultType>
    let results: NSArray
}

public final class DataStore: NSObject, ObservableObject {

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

    var result: Result<T, Error>!
    context.performAndWait {
        result = Result(catching: operation)
    }
    return try result.get()
}

private enum PreviewPersistenceStores {
    static let result: Result<PersistenceStores, Error> = Result {
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
