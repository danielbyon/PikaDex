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

@propertyWrapper
public struct Query<T: Queryable>: DynamicProperty {

    @StateObject private var core = QueryObserver<T>()
    @State private var baseFilter: T.Filter

    @Dependency(\.pokedexDataStore) private var dependencyDataStore

    public var wrappedValue: QueryResults<T> { core.results }

    public var projectedValue: Binding<T.Filter> { $baseFilter }

    private let explicitDataStore: DataStore?

    public init(
        _ filter: T.Filter = .default,
        dataStore: DataStore? = nil
    ) {
        self._baseFilter = .init(initialValue: filter)
        self.explicitDataStore = dataStore
    }

    public func update() {
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
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.update(filter: filter, dataStore: dataStore)
            }
            return
        }

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
        guard controller === self.controller else { return }
        let results = (controller.fetchedObjects as NSArray?) ?? NSArray()
        let currentGeneration = generation

        publishOnMain { [weak self] in
            guard let self,
                  self.generation == currentGeneration,
                  controller === self.controller else { return }
            self.diagnosticError = nil
            self.publish(QueryResults(results: results, state: .loaded))
        }
    }

    private func publish(_ results: QueryResults<T>) {
        precondition(Thread.isMainThread, "Query state must be published on the main thread")
        objectWillChange.send()
        self.results = results
        stateDidChange?(results.state)
    }

    private func publishOnMain(_ operation: @escaping () -> Void) {
        if Thread.isMainThread {
            operation()
        } else {
            DispatchQueue.main.async(execute: operation)
        }
    }
}
