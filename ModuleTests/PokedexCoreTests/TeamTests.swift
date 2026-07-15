import XCTest

@testable import PokedexCore

final class TeamTests: XCTestCase {

    func testPokePasteFullSnapshot() {
        let team = Team(
            name: "Some Team",
            members: [
                TeamMember(
                    pokemon: "Bulbasaur",
                    formName: "Bulbasaur",
                    nickname: "",
                    level: 100,
                    hp: .init(baseValue: 45, ev: 0, iv: 31),
                    attack: .init(baseValue: 49, ev: 252, iv: 0),
                    defense: .init(baseValue: 49, ev: 6, iv: 14),
                    specialAttack: .init(baseValue: 65, ev: 252, iv: 31),
                    specialDefense: .init(baseValue: 65, ev: 0, iv: 16),
                    speed: .init(baseValue: 45, ev: 0, iv: 4),
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
                    internalID: UUID(uuidString: "16A520B2-1F21-4DAF-8148-E461D2EE2D93")!
                ),
                TeamMember(
                    pokemon: "Charizard",
                    formName: "Mega Charizard X",
                    nickname: "",
                    level: 50,
                    hp: .init(baseValue: 78, ev: 0, iv: 0),
                    attack: .init(baseValue: 130, ev: 0, iv: 0),
                    defense: .init(baseValue: 111, ev: 0, iv: 0),
                    specialAttack: .init(baseValue: 130, ev: 0, iv: 0),
                    specialDefense: .init(baseValue: 85, ev: 0, iv: 0),
                    speed: .init(baseValue: 100, ev: 0, iv: 0),
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
                    internalID: UUID(uuidString: "2D90D5CE-A287-4927-9C9A-FE27994B9606")!
                )
            ],
            internalID: UUID(uuidString: "15E06196-A0BA-49C7-9AA7-FA05EDC6F8D4")!
        )

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

        XCTAssertEqual(team.pokePaste, expected)
        XCTAssertEqual(team.pokePaste.components(separatedBy: "\n\n").count, 2)
        XCTAssertFalse(team.pokePaste.hasSuffix("\n"))
    }

    func testPokePasteFocusedOptionalFormatting() {
        let team = Team(
            name: "Focused",
            members: [
                makeMember(
                    pokemon: "Pikachu",
                    formName: "Pikachu",
                    nickname: "Sparky",
                    move1: "Thunderbolt",
                    move3: "Quick Attack",
                    happiness: 200,
                    isShiny: true,
                    gender: .female
                ),
                makeMember(
                    pokemon: "Tauros",
                    formName: "Tauros Paldean Combat Breed",
                    nickname: "",
                    gender: .unspecified
                )
            ]
        )

        let exportedMembers = team.pokePaste.components(separatedBy: "\n\n")
        XCTAssertEqual(exportedMembers.count, 2)
        XCTAssertTrue(exportedMembers[0].hasPrefix("Sparky (Pikachu) (F)\n"))
        XCTAssertTrue(exportedMembers[0].contains("Shiny: Yes\nLevel: 50\nHappiness: 200"))
        XCTAssertTrue(exportedMembers[0].hasSuffix("- Thunderbolt\n- Quick Attack"))
        XCTAssertTrue(exportedMembers[1].hasPrefix("Tauros-Paldean-Combat-Breed\n"))
        XCTAssertFalse(exportedMembers[1].contains("Ability:"))
        XCTAssertFalse(exportedMembers[1].contains("Nature"))
        // An empty move list remains an empty final component, preserving the
        // formatter's existing trailing-newline behavior for this case.
        XCTAssertTrue(team.pokePaste.hasSuffix("\n"))
    }

    func testEmptyTeamHasEmptyExportWithoutFinalNewline() {
        let output = Team(name: "Empty").pokePaste

        XCTAssertEqual(output, "")
        XCTAssertFalse(output.hasSuffix("\n"))
    }

    private func makeMember(
        pokemon: String,
        formName: String,
        nickname: String,
        move1: String? = nil,
        move3: String? = nil,
        happiness: Int = 255,
        isShiny: Bool = false,
        gender: Gender
    ) -> TeamMember {
        let stat = TeamMember.Stat(baseValue: 50, ev: 0, iv: 31)
        return TeamMember(
            pokemon: pokemon,
            formName: formName,
            nickname: nickname,
            level: 50,
            hp: stat,
            attack: stat,
            defense: stat,
            specialAttack: stat,
            specialDefense: stat,
            speed: stat,
            move1: move1,
            move2: nil,
            move3: move3,
            move4: nil,
            nature: nil,
            ability: nil,
            heldItem: nil,
            happiness: happiness,
            isShiny: isShiny,
            gender: gender,
            game: .scarlet,
            internalID: UUID(uuidString: "4A58C20E-6D8A-4F09-8597-53A5F942D156")!
        )
    }
}
