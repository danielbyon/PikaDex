//
//  EvolutionTests.swift
//  DatabaseTests
//
//  Created by Daniel Byon on 1/3/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import XCTest
import CoreData
@testable import Pokepedia

class EvolutionTests: ModelObjectBaseTestCase {

    typealias Subject = Evolution
    
    func testProperties() {
        let sut = Subject(context: context)
        
        sut.name = "Bulbasaur"

        validateString(sut.name)
    }

}
