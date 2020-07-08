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

    private var cancellables: Set<AnyCancellable> = []
    private var saveWorkItem: DispatchWorkItem?
    private let teamsKey = "teams"

    private enum Constant {
        static func teamsKey(forGame game: Game) -> String { "teams-\(game.rawValue)" }
    }

    init(game: Game) {
        self.game = game
        load()
        objectWillChange.sink { [unowned self] _ in
            self.scheduleSave()
        }.store(in: &cancellables)
    }

    func addNewTeam() -> TeamViewModel {
        let viewModel = TeamViewModel(name: "New Team", members: [], internalID: .init())
        teams.append(viewModel)
        setupObservation(for: viewModel)
        return viewModel
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
        do {
            guard let data = UserDefaults.standard.data(forKey: Constant.teamsKey(forGame: game)) else { return }
            let teams = try JSONDecoder().decode([Team].self, from: data)
            let viewModels = teams.map { TeamViewModel(name: $0.name, members: $0.members.map { .init(teamMember: $0) }, internalID: $0.internalID) }
            viewModels.forEach { setupObservation(for: $0) }
            self.teams = viewModels
        } catch {
            debugPrint(error)
        }
    }

    private func scheduleSave() {
        saveWorkItem?.cancel()
        let saveWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.save()
            self.saveWorkItem = nil
        }
        self.saveWorkItem = saveWorkItem
        DispatchQueue
            .main
            .asyncAfter(deadline: .now() + 0.2, execute: saveWorkItem)
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(teams.map { $0.makeTeam() })
            UserDefaults.standard.set(data, forKey: Constant.teamsKey(forGame: game))
        } catch {
            debugPrint(error)
        }
    }

    private func setupObservation(for team: TeamViewModel) {
        team.objectWillChange.sink { [unowned self] in
            self.objectWillChange.send()
            self.scheduleSave()
        }.store(in: &cancellables)
    }

}
