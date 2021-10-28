//
//  QueryResults.swift
//  Pokedex
//
//  Created by Daniel Byon on 10/19/21.
//  Copyright © 2021 Daniel Byon. All rights reserved.
//

import Foundation

public struct QueryResults<T: Queryable>: RandomAccessCollection {

    public var count: Int { results.count }
    public var startIndex: Int { 0 }
    public var endIndex: Int { count }

    private let results: NSArray

    init(results: NSArray = NSArray()) {
        self.results = results
    }

    public subscript(position: Int) -> T {
        let object = results.object(at: position) as! T.Filter.ResultType
        return T(result: object)
    }

}
