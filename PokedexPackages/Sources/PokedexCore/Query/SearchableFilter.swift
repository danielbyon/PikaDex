//
//  SearchableFilter.swift
//  Pokedex
//
//  Created by Daniel Byon on 9/16/22.
//  Copyright © 2022 Daniel Byon. All rights reserved.
//

import Foundation

public protocol SearchableFilter: QueryFilter {

    var query: String { get set }

}
