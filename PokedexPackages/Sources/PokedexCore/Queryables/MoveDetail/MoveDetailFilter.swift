//
//  MoveDetailFilter.swift
//  
//
//  Created by Daniel Byon on 9/29/22.
//

import CoreData
import Foundation

public struct MoveDetailFilter: QueryFilter {

    public typealias ResultType = StoredMove

    public static var `default`: MoveDetailFilter {
        return .init()
    }

    public init() {

    }

    public func makeFetchRequest(_ dataStore: DataStore) -> NSFetchRequest<StoredMove> {
        fatalError()
    }

}
