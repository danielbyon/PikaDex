//
//  FormInfoTests.swift
//  DatabaseTests
//
//  Created by Daniel Byon on 1/3/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import XCTest
import CoreData
@testable import Pokepedia

class FormInfoTests: ModelObjectBaseTestCase {

    typealias Subject = PokemonForm
    
    func testProperties() {
        let sut = Subject(context: context)

        let baseStats = Stats(context: context)
        let evYield = Stats(context: context)
        let hiddenAbility = Ability(context: context)
        hiddenAbility.name = "Hidden"
        let primaryAbility = Ability(context: context)
        primaryAbility.name = "Primary"
        let secondaryAbility = Ability(context: context)
        secondaryAbility.name = "Secondary"

        sut.baseExperienceYield = 60
        sut.baseFriendship = 70
        sut.color = .blue
        sut.formIndex = 0
        sut.heightInMeters = 2.3
        sut.name = "Zapdos"
        sut.pokedexEntry = "Blah blah pokemon entry"
        sut.primaryType = .electric
        sut.secondaryType = .flying
        sut.weightInKilograms = 54.2
        sut.baseStats = baseStats
        sut.evYield = evYield
        sut.hiddenAbility = hiddenAbility
        sut.primaryAbility = primaryAbility
        sut.secondaryAbility = secondaryAbility

        validateInt(sut.baseExperienceYield)
        validateInt(sut.baseFriendship)
        validateString(sut.color.rawValue)
        validateInt(sut.formIndex)
        validateDouble(sut.heightInMeters)
        validateString(sut.name)
        validateString(sut.pokedexEntry)
        validateString(sut.primaryType.rawValue)
        validateString(sut.secondaryType!.rawValue)
        validateDouble(sut.weightInKilograms)
        validateRelationshipObject(sut.baseStats, expected: baseStats)
        validateRelationshipObject(sut.evYield, expected: evYield)
        validateRelationshipObject(sut.hiddenAbility, expected: hiddenAbility)
        validateRelationshipObject(sut.primaryAbility, expected: primaryAbility)
        validateRelationshipObject(sut.secondaryAbility, expected: secondaryAbility)
    }

}
