//
//  StatCalculatorTests.swift
//  PokedexTests
//
//  Created by Daniel Byon on 6/22/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import XCTest
@testable import PikaDex

class StatCalculatorTests: XCTestCase {

    let baseHP = 60
    let baseAttack = 45
    let baseDefense = 50
    let baseSpecialAttack = 80
    let baseSpecialDefense = 80
    let baseSpeed = 70

    let hpIV = 28
    let attackIV = 4
    let defenseIV = 17
    let specialAttackIV = 30
    let specialDefenseIV = 27
    let speedIV = 31

    let hpEV = 4
    let attackEV = 0
    let defenseEV = 0
    let specialAttackEV = 254
    let specialDefenseEV = 0
    let speedEV = 252

    let level = 53
    let nature: Nature = .modest

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testHP() {
        let calculated = StatCalculator.calculateStat(statType: .hp, baseValue: baseHP, iv: hpIV, ev: hpEV, level: level, nature: nature, game: .black)
        XCTAssertEqual(calculated, 141)
    }

    func testAttack() {
        let calculated = StatCalculator.calculateStat(statType: .attack, baseValue: baseAttack, iv: attackIV, ev: attackEV, level: level, nature: nature, game: .black)
        XCTAssertEqual(calculated, 48)
    }

    func testDefense() {
        let calculated = StatCalculator.calculateStat(statType: .defense, baseValue: baseDefense, iv: defenseIV, ev: defenseEV, level: level, nature: nature, game: .black)
        XCTAssertEqual(calculated, 67)
    }

    func testSpecialAttack() {
        let calculated = StatCalculator.calculateStat(statType: .specialAttack, baseValue: baseSpecialAttack, iv: specialAttackIV, ev: specialAttackEV, level: level, nature: nature, game: .black)
        XCTAssertEqual(calculated, 152)
    }

    func testSpecialDefense() {
        let calculated = StatCalculator.calculateStat(statType: .specialDefense, baseValue: baseSpecialDefense, iv: specialDefenseIV, ev: specialDefenseEV, level: level, nature: nature, game: .black)
        XCTAssertEqual(calculated, 104)
    }

    func testSpeed() {
        let calculated = StatCalculator.calculateStat(statType: .speed, baseValue: baseSpeed, iv: speedIV, ev: speedEV, level: level, nature: nature, game: .black)
        XCTAssertEqual(calculated, 129)
    }

}
