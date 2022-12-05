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
    private var cache: NSMutableDictionary

    init(results: NSArray = NSArray()) {
        self.results = results
        self.cache = .init(capacity: results.count)
    }

    public subscript(position: Int) -> T {
        if let cached = cache[position] as? T {
            return cached
        }
        let object = results.object(at: position) as! T.Filter.ResultType
        let retVal = T(result: object)
        cache[position] = retVal
        return retVal
    }

    public func map<U>(_ transform: @escaping (T) -> U) -> MappedQueryResults<T, U> {
        return MappedQueryResults(base: results, transform: transform)
    }

}

public struct MappedQueryResults<Base, Target>: RandomAccessCollection {

    public typealias Element = Target

    public var count: Int { base.count }
    public var startIndex: Int { 0 }
    public var endIndex: Int { count }

    private let base: NSArray
    private let transform: (Base) -> Target
    private var cache: NSMutableDictionary

    init(base: NSArray, transform: @escaping (Base) -> Target) {
        self.base = base
        self.transform = transform
        self.cache = .init(capacity: base.count)
    }

    public subscript(position: Int) -> Target {
        if let cached = cache[position] as? Target {
            return cached
        }
        let base = base.object(at: position) as! Base
        let retVal = transform(base)
        cache[position] = retVal
        return retVal
    }

}

//public struct ErasedQueryResults<T>: RandomAccessCollection {
//
//    public var count: Int { base.count }
//    public var startIndex: Int { 0 }
//    public var endIndex: Int { count }
//
//    private let base: any RandomAccessCollection
//
//    init<Base>(base: Base) where Base: RandomAccessCollection {
//        self.base = base
//    }
//
//    public subscript(position: Int) -> T {
//        return getObject(atPosition: position, collection: base)
//    }
//
//    private func getObject(atPosition position: Int, collection: some RandomAccessCollection) -> T {
//        return collection[collection.startIndex.advanced(by: position)] as! T
//    }
//
//}
