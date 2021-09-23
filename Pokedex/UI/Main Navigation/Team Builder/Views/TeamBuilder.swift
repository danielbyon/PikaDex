//
//  TeamBuilder.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/22/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct TeamBuilder: View {

    let game: Game

    @Environment(\.editMode) var editMode
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var currentEditingTeam: TeamViewModel?
    @State private var currentDeletingTeam: TeamViewModel?
    @State private var isShowingDeleteConfirmation = false
    @State private var isShowingPokepasteExport = false
    @StateObject var viewModel: TeamBuilderViewModel

    private var numberOfColumns: Int { horizontalSizeClass == .regular ? 2 : 1 }

    var body: some View {
        content()
            .overlay {
                emptyState()
                    .opacity(viewModel.teams.isEmpty ? 1.0 : 0.0)
            }
            .navigationTitle("Teams")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    EditButton()
                    Button(action: viewModel.addNewTeam) {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert(isPresented: $isShowingPokepasteExport) {
                Alert(
                    title: Text("Copied to clipboard!"),
                    message: Text("Your team has been exported to the PokéPaste format and copied to the clipboard."),
                    dismissButton: .default(Text("Dismiss")))
            }
            .confirmationDialog("Delete Team?", isPresented: $isShowingDeleteConfirmation, presenting: currentDeletingTeam) { team in
                Button(role: .destructive) {
                    withAnimation {
                        viewModel.deleteTeam(team)
                    }
                } label: {
                    Text("Delete")
                }
                Button(role: .cancel, action: {}) {
                    Text("Cancel")
                }
            } message: { _ in
                Text("This action cannot be undone.")
            }
            .onOpenURL(perform: handleURL)
    }

    init(game: Game) {
        self.game = game
        self._viewModel = .init(wrappedValue: .init(game: game))
    }

    private func emptyState() -> some View {
        Text("No teams")
            .monospacedBody()
    }

    private func content() -> some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: .init(), count: numberOfColumns), alignment: .leading, spacing: 24.0) {
                Section(footer: footer()) {
                    ForEach(viewModel.teams) { team in
                        NavigationLink(destination: TeamEditor(viewModel: team, game: viewModel.game), tag: team, selection: $currentEditingTeam) {
                            teamItemCell(team: team)
                        }
                    }
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private func footer() -> some View {
        if !viewModel.teams.isEmpty {
            #if targetEnvironment(macCatalyst)
            Text("Right-click on a team for options")
                .monospacedCaption()
            #else
            Text("Tap and hold on a team for options")
                .monospacedCaption()
            #endif
        }
    }

    private func teamItemCell(team: TeamViewModel) -> some View {
        TeamCell(team: team)
            .contextMenu {
                Button(role: .destructive) {
                    currentDeletingTeam = team
                    isShowingDeleteConfirmation = true
                } label: {
                    Label("Delete", image: "trash")
                }
                Button(role: nil) {
                    viewModel.exportTeam(team)
                    isShowingPokepasteExport = true
                } label: {
                    Label("Export PokéPaste", image: "share")
                }
            }
            .overlay(
                DeleteButton {
                    currentDeletingTeam = team
                    isShowingDeleteConfirmation = true
                }.opacity(editMode?.wrappedValue.isEditing == true ? 1.0 : 0.0),
                alignment: .topTrailing
            )
    }

    private func handleURL(_ url: URL) {
        guard let teamID = url.teamID,
              let team = viewModel.teams.first(where: { $0.internalID.uuidString == teamID }) else { return }
        currentEditingTeam = team
    }

}

struct TeamBuilder_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                TeamBuilder(game: .sword)
            }
            NavigationView {
                TeamBuilder(game: .sword)
            }
            .colorScheme(.dark)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .injectDependencies()
    }
}

private struct TeamCell: View {

    @ObservedObject var team: TeamViewModel

    private var emptySlots: [Marker] { Array([.init(index: 0), .init(index: 1), .init(index: 2), .init(index: 3), .init(index: 4), .init(index: 5)].dropFirst(team.members.count)) }

    var body: some View {
        Card {
            VStack(alignment: .leading) {
                HStack {
                    Text(team.name)
                        .monospacedTitle()
                        .bold()
                    Spacer()
                }
                Card {
                    HStack(spacing: 0) {
                        ForEach(team.members) { member in
                            if !self.team.isFirstMember(member) {
                                Spacer(minLength: 0)
                            }
                            PokemonFormSprite(form: member.pokemonForm)
                        }
                        if team.members.count < 6 {
                            ForEach(emptySlots) { i in
                                if (self.team.members.count > 0 || i.index > 0) {
                                    Spacer(minLength: 0)
                                }
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width: 40, height: 40)
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct Marker: Identifiable {

    let index: Int
    let id = UUID().uuidString

}
