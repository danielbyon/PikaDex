//
//  Queryable.swift
//  Pokedex
//
//  Created by Daniel Byon on 10/19/21.
//  Copyright © 2021 Daniel Byon. All rights reserved.
//

import Foundation

public protocol Queryable {

    associatedtype Filter: QueryFilter

    init(result: Filter.ResultType)

}
