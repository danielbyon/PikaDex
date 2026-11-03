//
//  TeamViewModel.swift
//  
//
//  Created by Daniel Byon on 10/28/22.
//

import Combine
import Dependencies
import SwiftUI

/// Main-actor observable state for one team detail interface.
@MainActor
public final class TeamViewModel: ObservableObject {

    var name: Binding<String> {
        .init { [unowned self] in
            self.team.name
        } set: { [unowned self] name in
            self.team.name = name
        }
    }

    @Published var team: Team
    @Published var members: [TeamMemberViewModel] = []

    let game: Game

    var canAddMembers: Bool {
        members.count < 6
    }

    @Dependency(\.teamStore) var teamStore
    private var cancellables: Set<AnyCancellable> = []

    public init(
        team: Team,
        game: Game
    ) {
        self.team = team
        self.game = game

        $team
            .handleEvents(receiveOutput: { [unowned self] team in
                self.members = team.members.map { .init(teamMember: $0, team: team) }
            })
            .dropFirst()
            .compactMap { $0 }
            .sink { [unowned self] updatedTeam in
                teamStore.saveTeam(updatedTeam, forGame: self.game)
            }
            .store(in: &cancellables)
    }

    func addMember(_ pokemonForm: PokemonDetailForm) {
        team.members.append(.init(pokemonForm: pokemonForm))
    }

    func removeMember(_ teamMember: TeamMember) {
        team.members.removeAll { $0.internalID == teamMember.internalID }
    }

}

extension TeamViewModel: Equatable {

    public static func == (lhs: TeamViewModel, rhs: TeamViewModel) -> Bool {
        lhs.name.wrappedValue == rhs.name.wrappedValue
        && lhs.team == rhs.team
        && lhs.members == rhs.members
        && lhs.game == rhs.game
    }

}

extension TeamViewModel: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name.wrappedValue)
        hasher.combine(team)
        hasher.combine(members)
        hasher.combine(game)
    }

}
