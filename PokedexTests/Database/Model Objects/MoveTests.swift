//
//  MoveTests.swift
//  DatabaseTests
//
//  Created by Daniel Byon on 1/3/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import XCTest
import CoreData
@testable import Pokepedia

class MoveTests: ModelObjectBaseTestCase {
    
    typealias Subject = Move
    
    func testProperties() {
        let sut = Subject(context: context)
        
        let info = MoveInfo(context: context)
        
        sut.generationIntroduced = .iv
        sut.index = 543
        sut.name = "Tackle"
        sut.type = .normal
        sut.game = .sword
        sut.info = info
        
        validateInt(sut.generationIntroduced.rawValue)
        validateInt(sut.index)
        validateString(sut.name)
        validateString(sut.type.rawValue)
        validateRelationshipObject(sut.info, expected: info)
    }

}
