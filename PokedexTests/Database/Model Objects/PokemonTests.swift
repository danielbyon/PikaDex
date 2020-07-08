//
//  PokemonTests.swift
//  DatabaseTests
//
//  Created by Daniel Byon on 1/3/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import XCTest
import CoreData
@testable import Pokepedia

class PokemonTests: ModelObjectBaseTestCase {
    
    typealias Subject = Pokemon
    
    func testProperties() {
        let sut = Subject(context: context)
        
        let pokedexNumbers = PokedexNumbers(context: context)
        let form1 = PokemonForm(context: context)
        form1.formIndex = 0
        let form2 = PokemonForm(context: context)
        form2.formIndex = 1
        let forms = [form1, form2]

        sut.catchRate = 255
        sut.eggGroups = [.monster]
        sut.generationIntroduced = .ii
        sut.index = 32
        sut.levelingRate = .mediumFast
        sut.maleRatio = 0.5
        sut.name = "Onix"
        sut.pokedexNumbers = pokedexNumbers
        sut.forms = forms

        validateInt(sut.catchRate)
        validateString(sut.eggGroups.map { $0.rawValue }.joined(separator: ","))
        validateInt(sut.generationIntroduced.rawValue)
        validateInt(sut.index)
        validateString(sut.levelingRate.rawValue)
        validateDouble(sut.maleRatio!)
        validateString(sut.name)
        validateRelationshipObject(sut.pokedexNumbers, expected: pokedexNumbers)
        validateRelationshipObjects(sut.forms, expected: forms)
    }

}
