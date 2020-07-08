//
//  AbilityTests.swift
//  DatabaseTests
//
//  Created by Daniel Byon on 1/3/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import XCTest
import CoreData
@testable import Pokepedia

class AbilityTests: ModelObjectBaseTestCase {

    typealias Subject = Ability
    
    func testProperties() {
        let sut = Subject(context: context)
        
        sut.generationIntroduced = .iii
        sut.index = 9
        sut.name = "Static"
        sut.setDescription("Paralyzes on contact.", forGame: .sword)

        validateInt(sut.generationIntroduced.rawValue)
        validateInt(sut.index)
        validateString(sut.name)
        validateString(sut.description(forGame: .sword) ?? _missingString)
    }

}
