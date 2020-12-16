//
//  TeamBuilderViewModel.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/22/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI
import Combine

class TeamBuilderViewModel: ObservableObject {

    let game: Game

    @Published var teams: [TeamViewModel] = []

    private let storage = TeamStorage()
    private var cancellables: Set<AnyCancellable> = []
    private var saveWorkItem: DispatchWorkItem?

    init(game: Game) {
        self.game = game
        load()
        objectWillChange.sink { [unowned self] _ in
            self.scheduleSave()
        }.store(in: &cancellables)
    }

    func addNewTeam() {
        let viewModel = TeamViewModel(name: "New Team", members: [], internalID: .init())
        teams.append(viewModel)
        setupObservation(for: viewModel)
    }

    func deleteTeam(_ team: TeamViewModel) {
        teams.removeAll { $0.internalID == team.internalID }
    }

    func removeTeams(atOffsets offsets: IndexSet) {
        teams.remove(atOffsets: offsets)
    }
    func exportTeam(_ viewModel: TeamViewModel) {
        let team = viewModel.makeTeam()
        UIPasteboard.general.string = team.pokePaste
    }

    private func load() {
        guard let teams = storage.loadTeams(forGame: game) else {
            self.teams = []
            return
        }
        let viewModels = teams.map { TeamViewModel(name: $0.name, members: $0.members.map { .init(teamMember: $0) }, internalID: $0.internalID) }
        viewModels.forEach { setupObservation(for: $0) }
        self.teams = viewModels
    }

    private func scheduleSave() {
        DispatchQueue.main.async {
            self.save()
        }
    }

    func save() {
        let teamsToSave = teams.map { $0.makeTeam() }
        storage.saveTeams(teamsToSave, forGame: game)
    }

    private func setupObservation(for team: TeamViewModel) {
        team.objectWillChange.sink { [unowned self] in
            self.objectWillChange.send()
            self.scheduleSave()
        }.store(in: &cancellables)
    }

}
