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

    @StateObject private var core = Core()
    @State private var baseFilter: T.Filter

    public var wrappedValue: QueryResults<T> { core.results }

    public var projectedValue: Binding<T.Filter> { $baseFilter }

    private let dataStore: DataStore

    private class Core: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {

        private(set) var results: QueryResults<T> = QueryResults()

        var dataStore: DataStore!
        var filter: T.Filter?

        private var controller: NSFetchedResultsController<T.Filter.ResultType>?

        func fetchIfNecessary() {
            guard let filter = filter else {
                fatalError("Attempting to execute a query without a filter")
            }

            var shouldFetch = false

            guard case .success(let viewContext) = dataStore.contextResult else {
                debugPrint("Core Data query could not start because persistence is unavailable.")
                return
            }

            let request = filter.makeFetchRequest(dataStore)
            request.returnsObjectsAsFaults = false
            request.fetchBatchSize = DatabaseConstants.fetchBatchSize
            if let controller = controller {
                if controller.fetchRequest.predicate != request.predicate {
                    controller.fetchRequest.predicate = request.predicate
                    shouldFetch = true
                }
                if controller.fetchRequest.sortDescriptors != request.sortDescriptors {
                    controller.fetchRequest.sortDescriptors = request.sortDescriptors
                    shouldFetch = true
                }
                controller.fetchRequest.returnsObjectsAsFaults = false
                controller.fetchRequest.fetchBatchSize = DatabaseConstants.fetchBatchSize
            } else {
                let controller = NSFetchedResultsController(
                    fetchRequest: request,
                    managedObjectContext: viewContext,
                    sectionNameKeyPath: nil,
                    cacheName: nil
                )
                controller.delegate = self
                self.controller = controller
                shouldFetch = true
            }

            if shouldFetch {
                let start = Date()
                try? controller?.performFetch()
                let end = Date()
                let duration = end.timeIntervalSince(start)
                print("Took \(duration) to fetch")
                updateResults()
            }
        }

        private func updateResults() {
            let resultsArray = (controller?.fetchedObjects as NSArray?) ?? NSArray()
            results = QueryResults(results: resultsArray)
        }

        func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            objectWillChange.send()
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            updateResults()
        }

    }

    public init(
        _ filter: T.Filter = .default,
        dataStore: DataStore? = nil
    ) {
        @Dependency(\.pokedexDataStore) var defaultDataStore
        self._baseFilter = .init(initialValue: filter)
        self.dataStore = dataStore ?? defaultDataStore
        if self.baseFilter != filter {
            self.baseFilter = filter
        }
    }

    public func update() {
        debugPrint("Query property wrapper update() called")
        if core.dataStore == nil {
            core.dataStore = dataStore
        }
        core.filter = baseFilter
        core.fetchIfNecessary()
    }

}
