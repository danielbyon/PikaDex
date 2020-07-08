//
//  MoveInfoTests.swift
//  DatabaseTests
//
//  Created by Daniel Byon on 1/3/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import XCTest
import CoreData
@testable import Pokepedia

class MoveInfoTests: ModelObjectBaseTestCase {
    
    typealias Subject = MoveInfo
    
    func testProperties() {
        let sut = Subject(context: context)
        
        sut.accuracy = 85
        sut.category = .physical
        sut.maxPP = 13
        sut.moveDescription = "Hits the Pokemon hard"
        sut.power = 140
        sut.pp = 5
        sut.priority = 0
        sut.targetAlly1 = true
        sut.targetAlly2 = true
        sut.targetEnemy1 = true
        sut.targetEnemy2 = true
        sut.targetEnemy3 = true
        sut.targetSelf = true
        
        validateInt(sut.accuracy)
        validateString(sut.category.rawValue)
        validateInt(sut.maxPP)
        validateString(sut.moveDescription)
        validateInt(sut.power)
        validateInt(sut.pp)
        validateInt(sut.priority)
        validateBool(sut.targetAlly1)
        validateBool(sut.targetAlly2)
        validateBool(sut.targetEnemy1)
        validateBool(sut.targetEnemy2)
        validateBool(sut.targetEnemy3)
        validateBool(sut.targetSelf)
    }

}
