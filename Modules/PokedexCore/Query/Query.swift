//
//  Query.swift
//  Pokedex
//
//  Created by Daniel Byon on 10/19/21.
//  Copyright © 2021 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData
import Dependencies
import SwiftUI

/// Exposes Core Data query results and filter bindings to SwiftUI on the main actor.
@propertyWrapper
public struct Query<T: Queryable>: @preconcurrency DynamicProperty {

    @StateObject private var core = QueryObserver<T>()
    @State private var baseFilter: T.Filter

    @Dependency(\.pokedexDataStore) private var dependencyDataStore

    @MainActor public var wrappedValue: QueryResults<T> { core.results }

    @MainActor public var projectedValue: Binding<T.Filter> { $baseFilter }

    private let explicitDataStore: DataStore?

    @MainActor public init(
        _ filter: T.Filter = .default,
        dataStore: DataStore? = nil
    ) {
        self._baseFilter = .init(initialValue: filter)
        self.explicitDataStore = dataStore
    }

    @MainActor public func update() {
        core.update(
            filter: baseFilter,
            dataStore: explicitDataStore ?? dependencyDataStore
        )
    }

}

/// Owns the lifecycle of one fetched-results controller for a SwiftUI query.
///
/// The observer is internal so tests can exercise lifecycle behavior directly
/// without turning controller details into public API.
/// Query state stays on the main queue. `update` requires main-thread use, and
/// observed stores require a main-queue context for fetched-results callbacks.
internal final class QueryObserver<T: Queryable>: NSObject, ObservableObject,
    NSFetchedResultsControllerDelegate {

    private struct Input: Equatable {
        let filter: T.Filter?
        let dataStoreIdentity: DataStoreIdentity
    }

    private(set) var results = QueryResults<T>()
    private(set) var controller: NSFetchedResultsController<T.Filter.ResultType>?
    private(set) var diagnosticError: Error?

    /// Optional lifecycle observation used by focused tests and diagnostics.
    var stateDidChange: ((QueryState) -> Void)?

    private var input: Input?
    private var generation = 0

    func update(filter: T.Filter?, dataStore: DataStore) {
        precondition(Thread.isMainThread, "Query updates must run on the main thread.")

        let newInput = Input(
            filter: filter,
            dataStoreIdentity: dataStore.identity
        )
        guard input != newInput else { return }

        input = newInput
        generation += 1
        let currentGeneration = generation

        if let controller {
            DataStore.detach(controller)
            self.controller = nil
        }

        guard let filter else {
            assertionFailure("Attempting to execute a query without a filter")
            diagnosticError = QueryError.missingFilter
            publish(results.updating(state: .failed(.missingFilter)))
            return
        }

        publish(results.updating(state: .loading))

        do {
            let observation: QueryObservation<T.Filter.ResultType> = try dataStore.makeObservation(
                for: filter,
                delegate: self
            )
            guard generation == currentGeneration else {
                DataStore.detach(observation.controller)
                return
            }
            controller = observation.controller
            diagnosticError = nil
            publish(QueryResults(results: observation.results, state: .loaded))
        } catch let error as ObservedQueryError {
            diagnosticError = error.underlyingError
            publish(results.updating(state: .failed(error.queryFailure)))
        } catch {
            diagnosticError = error
            publish(results.updating(state: .failed(.fetch)))
        }
    }

    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {
        precondition(Thread.isMainThread, "Fetched-results callbacks must run on the main thread.")
        guard controller === self.controller else { return }
        let results = (controller.fetchedObjects as NSArray?) ?? NSArray()
        diagnosticError = nil
        publish(QueryResults(results: results, state: .loaded))
    }

    private func publish(_ results: QueryResults<T>) {
        precondition(Thread.isMainThread, "Query state must be published on the main thread")
        objectWillChange.send()
        self.results = results
        stateDidChange?(results.state)
    }

}
