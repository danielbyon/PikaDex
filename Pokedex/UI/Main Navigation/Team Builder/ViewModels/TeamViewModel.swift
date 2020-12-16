//
//  TeamViewModel.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/22/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import Combine

class TeamViewModel: ObservableObject {

    @Published var name = ""
    @Published var members: [TeamMemberViewModel] = []
    let internalID: UUID

    private var cancellables: Set<AnyCancellable> = []

    init(name: String, members: [TeamMemberViewModel], internalID: UUID) {
        self.name = name
        self.members = members
        self.internalID = internalID
        members.forEach {
            self.setupObservation(for: $0)
        }
    }

    func addMember(_ pokemonForm: PokemonForm, game: Game) {
        let member = TeamMember(pokemonForm: pokemonForm, game: game)
        let viewModel = TeamMemberViewModel(teamMember: member)
        members.append(viewModel)
        setupObservation(for: viewModel)
    }

    func deleteMember(_ member: TeamMemberViewModel) {
        members.removeAll { $0.internalID == member.internalID }
    }

    func deleteMembers(atOffsets offsets: IndexSet) {
        members.remove(atOffsets: offsets)
    }

    func isFirstMember(_ member: TeamMemberViewModel) -> Bool {
        members.first?.internalID == member.internalID
    }

    func moveMembers(fromOffsets from: IndexSet, toOffset to: Int) {
        members.move(fromOffsets: from, toOffset: to)
    }

    func makeTeam() -> Team {
        let teamMembers = members.map { $0.makeTeamMember() }
        let team = Team(name: name, members: teamMembers, internalID: internalID)
        return team
    }

    private func setupObservation(for member: TeamMemberViewModel) {
        member.objectWillChange.sink { [unowned self] in
            self.objectWillChange.send()
        }.store(in: &cancellables)
    }

}

extension TeamViewModel: Equatable {

    static func == (lhs: TeamViewModel, rhs: TeamViewModel) -> Bool {
        lhs.internalID == rhs.internalID
    }

}

extension TeamViewModel: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(internalID)
    }

}

extension TeamViewModel: Identifiable {

    var id: String { internalID.uuidString }

}
