//
//  QueryFilter.swift
//  Pokedex
//
//  Created by Daniel Byon on 10/19/21.
//  Copyright © 2021 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

public protocol QueryFilter: Equatable {

    associatedtype ResultType: NSFetchRequestResult

    func makeFetchRequest(_ dataStore: DataStore) -> NSFetchRequest<ResultType>

}
