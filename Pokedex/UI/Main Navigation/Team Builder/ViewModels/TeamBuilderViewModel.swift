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

    var game: Game = .sword {
        didSet {
            refreshTeams()
        }
    }

    @Published var teams: [TeamViewModel] = []

    private let storage: TeamStorage
    private let notificationCenter: NotificationCenter
    private var cancellables: Set<AnyCancellable> = []
    private var didSetupSubscription = false

    static let teamsUpdatedNotification = Notification.Name("com.danielbyon.pikadex.teamsUpdated")

    init(storage: TeamStorage = .init(), notificationCenter: NotificationCenter = .default) {
        self.storage = storage
        self.notificationCenter = notificationCenter
    }

    private func refreshTeams() {
        let viewModels = storage.loadTeams(forGame: game)?
            .map {
                TeamViewModel(
                    name: $0.name,
                    members: $0.members.map { .init(teamMember: $0) },
                    internalID: $0.internalID
                )
            } ?? []
        teams = viewModels

        cancellables.removeAll()
        viewModels.forEach { setupObservation(for: $0) }
        objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                self.saveTeams(teams)
            }
            .store(in: &cancellables)
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

    private func saveTeams(_ teams: [TeamViewModel]) {
        let teamsToSave = teams.map { $0.makeTeam() }
        storage.saveTeams(teamsToSave, forGame: game)

        notificationCenter.post(name: Self.teamsUpdatedNotification, object: self)
    }

    private func setupObservation(for team: TeamViewModel) {
        team.objectWillChange
            .sink { [unowned self] in
                self.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

}
