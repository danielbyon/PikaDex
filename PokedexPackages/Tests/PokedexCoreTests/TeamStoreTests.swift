//
//  TeamStoreTests.swift
//  
//
//  Created by Daniel Byon on 10/27/22.
//

import CombineSchedulers
import XCTest

@testable import PokedexCore

final class TeamStoreTests: XCTestCase {

    var sut: DefaultTeamStore!
    var storage: TeamStorage!
    var scheduler: TestSchedulerOf<DispatchQueue>!

    override func setUp() {
        storage = .init(storage: UserDefaults(suiteName: UUID().uuidString)!)
        scheduler = DispatchQueue.test
    }

    func testLoadTeams() {
        let teams: [Team] = [.stub1]
        storage.saveTeams(teams, forGame: .sword)
        sut = .init(storage: storage, cacheScheduler: scheduler.eraseToAnyScheduler())

        XCTAssertEqual(sut[.sword], teams)
    }

    func testSaveTeam_triggersCacheFlush() {
        sut = .init(storage: storage, cacheScheduler: scheduler.eraseToAnyScheduler())

        let team = Team.stub1
        sut.saveTeam(team, forGame: .sword)

        XCTAssertNil(storage.loadTeams(forGame: .sword))

        scheduler.advance(by: 0.2)

        XCTAssertEqual(storage.loadTeams(forGame: .sword), [team])
    }

}
