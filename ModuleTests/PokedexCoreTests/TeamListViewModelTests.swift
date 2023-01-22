////
////  TeamListViewModelTests.swift
////  
////
////  Created by Daniel Byon on 10/26/22.
////
//
//import PokedexCore
//import SwiftUI
//import XCTest
//@testable import TeamFeature
//
//final class TeamListViewModelTests: XCTestCase {
//
//    private var sut: TeamListViewModel!
//    private var defaults: UserDefaults!
//    private var storage: TeamStorage!
//
//    override func setUp() {
//        super.setUp()
//        defaults = UserDefaults(suiteName: UUID().uuidString)!
//        storage = TeamStorage(storage: defaults)
//        sut = .init(teamStorage: storage)
//    }
//
//    func testTeamFetchFromStorage() {
//        storage.saveTeams([.stub], forGame: .sword)
//
//        sut.game = .sword
//
//        XCTAssertEqual(sut.sections.first?.teams.first, .stub)
//    }
//
//    func testTeamModification() {
//        storage.saveTeams([.stub], forGame: .sword)
//
//        let cancellable = sut.$sections
//            .sink { sections in
//
//            }
//
//        var stub = Team.stub
//
//    }
//
//}
//
//extension Team {
//
//    static var stub: Team {
//        .init(
//            name: "Test Team",
//            members: [
//                .init(
//                    pokemon: "Pikachu",
//                    formName: "Pikachu",
//                    nickname: "",
//                    level: 100,
//                    hp: .init(baseValue: 100, ev: 0, iv: 0),
//                    attack: .init(baseValue: 100, ev: 0, iv: 0),
//                    defense: .init(baseValue: 100, ev: 0, iv: 0),
//                    specialAttack: .init(baseValue: 100, ev: 0, iv: 0),
//                    specialDefense: .init(baseValue: 100, ev: 0, iv: 0),
//                    speed: .init(baseValue: 100, ev: 0, iv: 0),
//                    move1: nil,
//                    move2: nil,
//                    move3: nil,
//                    move4: nil,
//                    nature: nil,
//                    ability: nil,
//                    heldItem: nil,
//                    game: .sword,
//                    internalID: .init(uuidString: "EC0BB74E-E8CE-4512-86A1-061A09902D20")!
//                )
//            ],
//            internalID: .init(uuidString: "EC0BB74E-E8CE-4512-86A1-061A09902D20")!
//        )
//    }
//
//}
