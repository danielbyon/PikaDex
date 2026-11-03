//
//  QueryFilter.swift
//  Pokedex
//
//  Created by Daniel Byon on 10/19/21.
//  Copyright © 2021 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

/// Errors raised while a query filter constructs its fetch request.
///
/// These thrown values describe programming-level request construction
/// failures. SwiftUI-facing queries translate them into stable `QueryFailure`
/// values instead of exposing the underlying error instance as view state.
public enum QueryError: Error, Equatable {
    case missingFilter
    case unsupportedFilter(String)
}

public protocol QueryFilter: Equatable {

    associatedtype ResultType: NSManagedObject

    static var `default`: Self { get }

    /// Builds a deterministic request without executing it.
    ///
    /// Execution belongs to `DataStore`, which guarantees that Core Data work
    /// occurs on the managed-object context queue.
    func makeFetchRequest() throws -> NSFetchRequest<ResultType>

}
