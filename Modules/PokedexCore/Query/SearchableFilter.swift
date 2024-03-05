//
//  SearchableFilter.swift
//  Pokedex
//
//  Created by Daniel Byon on 9/16/22.
//  Copyright © 2022 Daniel Byon. All rights reserved.
//

import Foundation

public protocol SearchableFilter: QueryFilter {

    var query: SearchQuery { get set }

}

public enum SearchQuery: Hashable {
    case contains(String)
    case exact(String)

    public static var empty: Self { .contains("") }

    public var isEmpty: Bool {
        switch self {
        case .contains(let string), .exact(let string):
            return string.isEmpty
        }
    }
}
