//
//  TeamMemberViewModel.swift
//  
//
//  Created by Daniel Byon on 10/30/22.
//

import Combine
import PokedexUI
import SwiftUI

public final class TeamMemberViewModel: ObservableObject {

    @Published var teamMember: TeamMember

    var pokemonForm: PokemonDetailForm {
        try! dataStore.fetch(PokemonDetailForm.self, filter: PokemonDetailFormFilter(
            pokemonName: teamMember.pokemon,
            formName: teamMember.formName,
            game: teamMember.game
        )).first!
    }

    var ability: Ability? {
        get {
            guard let abilityName = teamMember.ability else { return nil }
            return try? dataStore.fetch(Ability.self, filter: AbilityFilter(
                game: teamMember.game,
                query: abilityName
            )).first
        }
        set { teamMember.ability = newValue?.name }
    }

    var game: Game { teamMember.game }

    var heldItem: Item? {
        get {
            guard let itemName = teamMember.heldItem else { return nil }
            return try? dataStore.fetch(Item.self, filter: ItemFilter(
                game: teamMember.game,
                query: itemName
            )).first
        }
        set { teamMember.heldItem = newValue?.name }
    }

    var ivRange: Range<Int> {
        if game.generation < 3 {
            return 0..<16
        } else {
            return 0..<32
        }
    }

    var level: Double {
        get { Double(teamMember.level) }
        set { teamMember.level = Int(newValue) }
    }

    var moves: [Move] { [move1, move2, move3, move4].compactMap { $0 } }

    var move1: Move? {
        get { fetchMove(forName: teamMember.move1) }
        set { teamMember.move1 = newValue?.name }
    }
    var move2: Move? {
        get { fetchMove(forName: teamMember.move2) }
        set { teamMember.move2 = newValue?.name }
    }
    var move3: Move? {
        get { fetchMove(forName: teamMember.move3) }
        set { teamMember.move3 = newValue?.name }
    }
    var move4: Move? {
        get { fetchMove(forName: teamMember.move4) }
        set { teamMember.move4 = newValue?.name }
    }

    var nature: Nature {
        get {
            guard let rawValue = teamMember.nature else { return .calm }
            return Nature[rawValue] ?? .calm
        }
        set {
            teamMember.nature = newValue.name
        }
    }

    private let team: Team
    private let dataStore: DataStore = .pokedex
    private let teamStore: TeamStore = DefaultTeamStore.shared

    private var cancellables: Set<AnyCancellable> = []

    private enum CodingKeys: String, CodingKey {
        case teamMember
        case team
    }

    public init(
        teamMember: TeamMember,
        team: Team
    ) {
        self.teamMember = teamMember
        self.team = team

        $teamMember
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] updatedTeamMember in
                debugPrint("Saving team member: \(updatedTeamMember.internalID)")
                var team = self.team
                guard let index = team.members.firstIndex(where: { $0.internalID == updatedTeamMember.internalID }) else { return }
                team.members[index] = updatedTeamMember
                self.teamStore.saveTeam(team, forGame: updatedTeamMember.game)
            }
            .store(in: &cancellables)
    }

    func remainingEVRange(forStatType statType: StatType) -> Range<Int> {
        if game.generation < 3 {
            return 0..<32
        } else {
            var endValue = 510
            if statType != .hp {
                endValue -= teamMember.hp.ev
            }
            if statType != .attack {
                endValue -= teamMember.attack.ev
            }
            if statType != .defense {
                endValue -= teamMember.defense.ev
            }
            if statType != .specialAttack {
                endValue -= teamMember.specialAttack.ev
            }
            if statType != .specialDefense {
                endValue -= teamMember.specialDefense.ev
            }
            if statType != .speed {
                endValue -= teamMember.speed.ev
            }

            let minimumEndValue: Int
            if game.generation < 6 {
                minimumEndValue = 255
            } else {
                minimumEndValue = 252
            }

            return 0..<(min(minimumEndValue, endValue) + 1) // Add one for ..< range
        }
    }

    private func fetchMove(forName name: String?) -> Move? {
        guard let name else { return nil }
        return try? dataStore.fetch(Move.self, filter: MoveFilter(game: teamMember.game, query: name)).first
    }

}

extension TeamMemberViewModel: Equatable {

    public static func == (lhs: TeamMemberViewModel, rhs: TeamMemberViewModel) -> Bool {
        lhs.teamMember == rhs.teamMember
        && lhs.team == rhs.team
    }

}

extension TeamMemberViewModel: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(teamMember.internalID)
        hasher.combine(team.internalID)
    }

}
