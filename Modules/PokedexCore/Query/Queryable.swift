//
//  Queryable.swift
//  Pokedex
//
//  Created by Daniel Byon on 10/19/21.
//  Copyright © 2021 Daniel Byon. All rights reserved.
//

import Foundation

/// Describes a value model created from a Core Data query result.
public protocol Queryable {

    associatedtype Filter: QueryFilter

    /// Copies the needed values without retaining the context-bound managed object.
    init(result: Filter.ResultType)

}
