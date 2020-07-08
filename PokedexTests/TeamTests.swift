//
//  TeamTests.swift
//  PokedexTests
//
//  Created by Daniel Byon on 7/7/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import XCTest
@testable import PikaDex

class TeamTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testPokePaste() throws {
        let team = Team(
            name: "Some Team",
            members: [
            .init(
                pokemon: "Bulbasaur",
                formName: "Bulbasaur",
                nickname: "",
                level: 100,
                hp: .init(
                    baseValue: 45,
                    ev: 0,
                    iv: 31),
                attack: .init(
                    baseValue: 49,
                    ev: 252,
                    iv: 0),
                defense: .init(
                    baseValue: 49,
                    ev: 6,
                    iv: 14),
                specialAttack: .init(
                    baseValue: 65,
                    ev: 252,
                    iv: 31),
                specialDefense: .init(
                    baseValue: 65,
                    ev: 0,
                    iv: 16),
                speed: .init(
                    baseValue: 45,
                    ev: 0,
                    iv: 4),
                move1: "Double-Edge",
                move2: "Razor Leaf",
                move3: "Leech Seed",
                move4: "Take Down",
                nature: "Calm",
                ability: "Overgrow",
                heldItem: "Oran Berry",
                happiness: 255,
                isShiny: false,
                gender: .unspecified,
                game: .sword,
                internalID: UUID()),
            .init(
                pokemon: "Charizard",
                formName: "Mega Charizard X",
                nickname: "",
                level: 50,
                hp: .init(
                    baseValue: 78,
                    ev: 0,
                    iv: 0),
                attack: .init(
                    baseValue: 130,
                    ev: 0,
                    iv: 0),
                defense: .init(
                    baseValue: 111,
                    ev: 0,
                    iv: 0),
                specialAttack: .init(
                    baseValue: 130,
                    ev: 0,
                    iv: 0),
                specialDefense: .init(
                    baseValue: 85,
                    ev: 0,
                    iv: 0),
                speed: .init(
                    baseValue: 100,
                    ev: 0,
                    iv: 0),
                move1: "Dragon Rage",
                move2: "Fire Spin",
                move3: "Flare Blitz",
                move4: "Flamethrower",
                nature: "Hardy",
                ability: "Tough Claws",
                heldItem: nil,
                happiness: 255,
                isShiny: true,
                gender: .male,
                game: .sword,
                internalID: UUID())
            ],
            internalID: UUID())

        let actual = team.pokePaste

        let expected =
        """
        Bulbasaur @ Oran Berry
        EVs: 0 HP / 252 Atk / 6 Def / 252 SpA / 0 SpD / 0 Spe
        IVs: 31 HP / 0 Atk / 14 Def / 31 SpA / 16 SpD / 4 Spe
        Ability: Overgrow
        Level: 100
        Calm Nature
        - Double-Edge
        - Razor Leaf
        - Leech Seed
        - Take Down

        Charizard-Mega-X (M)
        EVs: 0 HP / 0 Atk / 0 Def / 0 SpA / 0 SpD / 0 Spe
        IVs: 0 HP / 0 Atk / 0 Def / 0 SpA / 0 SpD / 0 Spe
        Ability: Tough Claws
        Shiny: Yes
        Level: 50
        Hardy Nature
        - Dragon Rage
        - Fire Spin
        - Flare Blitz
        - Flamethrower
        """

        XCTAssertEqual(actual, expected)
    }

}
