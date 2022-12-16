//
//  TeamListViewModel.swift
//  
//
//  Created by Daniel Byon on 10/26/22.
//

import Combine
import PokedexCore
import SwiftUI

final class TeamListViewModel: ObservableObject {

    // MARK: Properties

    var game: Game = .sword {
        didSet {
            if game != oldValue {
                reloadSections()
            }
        }
    }

    @Published var sections: [Section] = []
    var hasMultipleSections: Bool { sections.count > 1 }
    var shouldShowSectionHeaders: Bool { hasMultipleSections || game == .national }

    private let teamStore: TeamStore
    private var cancellables: Set<AnyCancellable> = []

    // MARK: Init

    init(teamStore: TeamStore = DefaultTeamStore.shared) {
        self.teamStore = teamStore
        teamStore.teams
            .sink { [unowned self] _ in
                self.reloadSections()
            }
            .store(in: &cancellables)
    }

    // MARK: Functions

    func addNewTeam(for game: Game) {
        let team = Team(name: "New Team")
        teamStore.saveTeam(team, forGame: game)
    }

    func removeTeam(_ team: Team, for game: Game) {
        var teams = teamStore.getTeams(forGame: game)
        teams.removeAll { $0.internalID == team.internalID }
        teamStore.setTeams(teams, forGame: game)
    }

    func exportTeam(_ team: Team) {
        UIPasteboard.general.string = team.pokePaste
    }

    func isLastSection(_ section: Section) -> Bool {
        section == sections.last
    }

    // MARK: Private

    private func reloadSections() {
        let gamesToLoad: [Game]
        if game == .national {
            gamesToLoad = Game.allGamesNewestFirst
        } else {
            gamesToLoad = [game]
        }

        let sections = gamesToLoad
            .map { game in
                Section(
                    game: game,
                    teams: teamStore
                        .getTeams(forGame: game)
                        .map { .init(team: $0, game: game) }
                )
            }
            .filter { !$0.teams.isEmpty }
        self.sections = sections
    }

}

extension TeamListViewModel {

    final class Section: ObservableObject {
        let game: Game
        @Published var teams: [TeamViewModel]

        init(game: Game, teams: [TeamViewModel]) {
            self.game = game
            self.teams = teams
        }
    }

}

extension TeamListViewModel.Section: Equatable {

    static func == (lhs: TeamListViewModel.Section, rhs: TeamListViewModel.Section) -> Bool {
        lhs.game == rhs.game
        && lhs.teams == rhs.teams
    }

}

extension TeamListViewModel.Section: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(game)
        hasher.combine(teams)
    }

}
