//
//  Query.swift
//  Pokedex
//
//  Created by Daniel Byon on 10/19/21.
//  Copyright © 2021 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData
import SwiftUI

@propertyWrapper
public struct Query<T: Queryable>: DynamicProperty {

//    @Environment(\.dataStore) var dataStore: DataStore
    @StateObject private var core = Core()
    @State private var baseFilter: T.Filter

    public var wrappedValue: QueryResults<T> { core.results }

    public var projectedValue: Binding<T.Filter> { $baseFilter }

    private let dataStore: DataStore

    private class Core: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {

        private(set) var results: QueryResults<T> = QueryResults()

        var dataStore: DataStore?
        var filter: T.Filter?

        private var controller: NSFetchedResultsController<T.Filter.ResultType>?

        func fetchIfNecessary() {
            guard let dataStore = dataStore else {
                fatalError("Attempting to execute a query but the DataStore is not in the environment")
            }
            guard let filter = filter else {
                fatalError("Attempting to execute a query without a filter")
            }

            var shouldFetch = false

            let request = filter.makeFetchRequest(dataStore)
            if let controller = controller {
                if controller.fetchRequest.predicate != request.predicate {
                    controller.fetchRequest.predicate = request.predicate
                    shouldFetch = true
                }
                if controller.fetchRequest.sortDescriptors != request.sortDescriptors {
                    controller.fetchRequest.sortDescriptors = request.sortDescriptors
                    shouldFetch = true
                }
            } else {
                let controller = NSFetchedResultsController(
                    fetchRequest: request,
                    managedObjectContext: dataStore.viewContext,
                    sectionNameKeyPath: nil,
                    cacheName: nil
                )
                controller.delegate = self
                self.controller = controller
                shouldFetch = true
            }

            if shouldFetch {
                try? controller?.performFetch()
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
        dataStore: DataStore = .pokedex
    ) {
        self._baseFilter = .init(initialValue: filter)
        self.dataStore = dataStore
        if self.baseFilter != filter {
            self.baseFilter = filter
        }
    }

    public func update() {
        if core.dataStore == nil {
            core.dataStore = dataStore
        }
        core.filter = baseFilter
        core.fetchIfNecessary()
    }

}
