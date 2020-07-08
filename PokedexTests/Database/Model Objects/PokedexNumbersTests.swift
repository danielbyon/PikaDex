//
//  PokedexNumbersTests.swift
//  DatabaseTests
//
//  Created by Daniel Byon on 1/3/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import XCTest
import CoreData
@testable import PikaDex

class PokedexNumbersTests: ModelObjectBaseTestCase {
    
    typealias Subject = PokedexNumbers
    
    func testProperties() {
        let sut = Subject(context: context)
        
        sut.akala = 1
        sut.alola = 2
        sut.centralKalos = 3
        sut.coastalKalos = 4
        sut.galar = 5
        sut.hoenn = 6
        sut.johto = 7
        sut.kanto = 8
        sut.melemele = 9
        sut.mountainKalos = 10
        sut.national = 11
        sut.newHoenn = 12
        sut.newJohto = 13
        sut.newUnova = 14
        sut.poni = 15
        sut.sinnoh = 16
        sut.ulaula = 17
        sut.ultraAkala = 18
        sut.ultraAlola = 19
        sut.ultraMelemele = 20
        sut.ultraPoni = 21
        sut.ultraUlaula = 22
        sut.unova = 23
        
        validateInt(sut.akala)
        validateInt(sut.alola)
        validateInt(sut.centralKalos)
        validateInt(sut.coastalKalos)
        validateInt(sut.galar)
        validateInt(sut.hoenn)
        validateInt(sut.johto)
        validateInt(sut.kanto)
        validateInt(sut.melemele)
        validateInt(sut.mountainKalos)
        validateInt(sut.national)
        validateInt(sut.newHoenn)
        validateInt(sut.newJohto)
        validateInt(sut.newUnova)
        validateInt(sut.poni)
        validateInt(sut.sinnoh)
        validateInt(sut.ulaula)
        validateInt(sut.ultraAkala)
        validateInt(sut.ultraAlola)
        validateInt(sut.ultraMelemele)
        validateInt(sut.ultraPoni)
        validateInt(sut.ultraUlaula)
        validateInt(sut.unova)
    }

}
