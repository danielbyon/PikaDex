//
//  Sequence+UniqueValues.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/20/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

extension Sequence where Self.Element: Equatable {

    var uniqueValues: [Element] {
        uniqingValues(by: ==)
    }

    func uniqingValues(by areUnique: (Element, Element) -> Bool) -> [Element] {
        var retVal: [Element] = []
        self.forEach { element in
            if !retVal.contains(where: { areUnique($0, element) }) {
                retVal.append(element)
            }
        }
        return retVal
    }

}
