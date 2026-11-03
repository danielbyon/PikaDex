import XCTest

@testable import PokedexCore

final class StatCalculatorTests: XCTestCase {

    private let baseHP = 60
    private let baseAttack = 45
    private let baseDefense = 50
    private let baseSpecialAttack = 80
    private let baseSpecialDefense = 80
    private let baseSpeed = 70

    private let hpIV = 28
    private let attackIV = 4
    private let defenseIV = 17
    private let specialAttackIV = 30
    private let specialDefenseIV = 27
    private let speedIV = 31

    private let hpEV = 4
    private let attackEV = 0
    private let defenseEV = 0
    private let specialAttackEV = 254
    private let specialDefenseEV = 0
    private let speedEV = 252

    private let level = 53
    private let nature: Nature = .modest

    func testHP() {
        XCTAssertEqual(calculate(.hp, base: baseHP, iv: hpIV, ev: hpEV), 141)
    }

    func testAttack() {
        XCTAssertEqual(calculate(.attack, base: baseAttack, iv: attackIV, ev: attackEV), 48)
    }

    func testDefense() {
        XCTAssertEqual(calculate(.defense, base: baseDefense, iv: defenseIV, ev: defenseEV), 67)
    }

    func testSpecialAttack() {
        XCTAssertEqual(calculate(.specialAttack, base: baseSpecialAttack, iv: specialAttackIV, ev: specialAttackEV), 152)
    }

    func testSpecialDefense() {
        XCTAssertEqual(calculate(.specialDefense, base: baseSpecialDefense, iv: specialDefenseIV, ev: specialDefenseEV), 104)
    }

    func testSpeed() {
        XCTAssertEqual(calculate(.speed, base: baseSpeed, iv: speedIV, ev: speedEV), 129)
    }

    func testNatureFactors() {
        let cases: [(name: String, nature: Nature, expected: Int)] = [
            ("increased", .adamant, 167),
            ("decreased", .modest, 136),
            ("neutral", .hardy, 152)
        ]

        for testCase in cases {
            let value = StatCalculator.calculateStat(
                statType: .attack,
                baseValue: 100,
                iv: 31,
                ev: 252,
                level: 50,
                nature: testCase.nature,
                game: .black
            )
            XCTAssertEqual(value, testCase.expected, testCase.name)
        }
    }

    func testPreAdvanceHPIVOddEvenBranches() {
        let cases: [(ivs: (Int, Int, Int, Int), expected: Int)] = [
            ((0, 0, 0, 0), 0),
            ((1, 0, 0, 0), 8),
            ((0, 1, 0, 0), 4),
            ((0, 0, 1, 0), 2),
            ((0, 0, 0, 1), 1),
            ((1, 1, 1, 1), 15)
        ]

        for testCase in cases {
            XCTAssertEqual(
                StatCalculator.calculatePreAdvanceHPIV(
                    attackIV: testCase.ivs.0,
                    defenseIV: testCase.ivs.1,
                    speedIV: testCase.ivs.2,
                    specialIV: testCase.ivs.3
                ),
                testCase.expected
            )
        }
    }

    private func calculate(_ statType: StatType, base: Int, iv: Int, ev: Int) -> Int {
        StatCalculator.calculateStat(
            statType: statType,
            baseValue: base,
            iv: iv,
            ev: ev,
            level: level,
            nature: nature,
            game: .black
        )
    }
}
