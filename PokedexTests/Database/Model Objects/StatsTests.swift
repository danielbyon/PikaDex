//
//  StatsTests.swift
//  DatabaseTests
//
//  Created by Daniel Byon on 1/3/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import XCTest
import CoreData
@testable import Pokepedia

class StatsTests: ModelObjectBaseTestCase {
    
    typealias Subject = Stats
    
    func testProperties() {
        let sut = Subject(context: context)
        
        sut.attack = 24
        sut.defense = 43
        sut.hp = 120
        sut.specialAttack = 43
        sut.specialDefense = 54
        sut.speed = 98
        
        validateInt(sut.attack)
        validateInt(sut.defense)
        validateInt(sut.hp)
        validateInt(sut.specialAttack)
        validateInt(sut.specialDefense)
        validateInt(sut.speed)
    }

}
