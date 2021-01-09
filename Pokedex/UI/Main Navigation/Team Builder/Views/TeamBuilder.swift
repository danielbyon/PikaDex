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
    @State private var currentAlert: AlertState?
    @StateObject var viewModel: TeamBuilderViewModel

    private var numberOfColumns: Int { horizontalSizeClass == .regular ? 2 : 1 }

    var body: some View {
        content()
            .if(viewModel.teams.isEmpty) { $0.overlay(emptyState()) }
            .navigationTitle("Teams")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    EditButton()
                    addNewTeamButton()
                }
            }
            .alert(item: $currentAlert, content: alertDestination)
            .onOpenURL(perform: handleURL)
    }

    private enum AlertState: Identifiable {

        case pokepasteExport
        case deleteTeam(TeamViewModel)

        var id: String {
            switch self {
            case .pokepasteExport:
                return "pokepasteExport"
            case .deleteTeam(let team):
                return "team_\(team.id)"
            }
        }

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
                Button("Delete") {
                    currentAlert = .deleteTeam(team)
                }
                Button("Export PokéPaste") {
                    self.viewModel.exportTeam(team)
                    currentAlert = .pokepasteExport
                }
            }
            .if(editMode?.wrappedValue.isEditing == true) {
                $0.overlay(DeleteButton {
                    currentAlert = .deleteTeam(team)
                }, alignment: .topTrailing)
            }
    }

    private func addNewTeamButton() -> some View {
        Button(action: viewModel.addNewTeam) {
            Image(systemName: "plus")
        }
    }

    private func alertDestination(_ state: AlertState) -> Alert {
        switch state {
        case .pokepasteExport:
            return Alert(
                title: Text("Copied to clipboard!"),
                message: Text("Your team has been exported to the PokéPaste format and copied to the clipboard."),
                dismissButton: .default(Text("Dismiss")))
        case .deleteTeam(let team):
            return Alert(
                title: Text("Delete team?"),
                message: Text("This action cannot be undone."),
                primaryButton: .cancel(),
                secondaryButton: .destructive(Text("Delete")) {
                    withAnimation {
                        viewModel.deleteTeam(team)
                    }
                })
        }
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
