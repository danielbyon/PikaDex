//
//  TeamList.swift
//  
//
//  Created by Daniel Byon on 10/26/22.
//

import PokedexUI
import SwiftUI

public struct TeamList<ViewFactory: TeamViewFactory>: View {

    let game: Game
    let viewFactory: ViewFactory

//    @Environment(\.editMode) var editMode
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var isShowingDeleteTeam = false
    @State private var isShowingPokepasteExport = false
    @State private var isShowingSelectGame = false
    @State private var currentDeletingTeam: TeamViewModel?
    @StateObject private var viewModel = TeamListViewModel()

    private var numberOfColumns: Int { horizontalSizeClass == .regular ? 2 : 1 }

    public var body: some View {
        content()
            .background {
                emptyState()
                    .opacity(viewModel.sections.isEmpty ? 1.0 : 0.0)
            }
            .navigationTitle("Teams")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    HomeButton()
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
//                    EditButton()
                    Button {
                        if game == .national {
                            isShowingSelectGame.toggle()
                        } else {
                            withAnimation {
                                viewModel.addNewTeam(for: game)
                            }
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .confirmationDialog("Add Team", isPresented: $isShowingSelectGame) {
                        selectGame()
                    }
                    .confirmationDialog(
                        "Delete Team?",
                        isPresented: $isShowingDeleteTeam,
                        presenting: currentDeletingTeam
                    ) { teamViewModel in
                        Button("Delete", role: .destructive) {
                            withAnimation {
                                viewModel.removeTeam(
                                    teamViewModel.team,
                                    for: teamViewModel.game
                                )
                            }
                        }
                        Button("Cancel", role: .cancel, action: { })
                    } message: { _ in
                        Text("This action cannot be undone.")
                    }
                }
            }
            .onAppear {
                viewModel.game = game
            }
            .onChange(of: game) { newValue in
                viewModel.game = newValue
            }
            .onOpenURL(perform: handleURL)
    }

    public init(
        game: Game,
        viewFactory: ViewFactory
    ) {
        self.game = game
        self.viewFactory = viewFactory
    }

    private func content() -> some View {
        ScrollView {
            LazyVGrid(
                columns: Array(repeating: .init(), count: numberOfColumns),
                alignment: .leading,
                spacing: 24.0
            ) {
                ForEach(viewModel.sections, id: \.self) { section in
                    Section {
                        ForEach(section.teams, id: \.team.id) { team in
                            NavigationLink {
                                TeamView(viewModel: team, viewFactory: viewFactory)
                            } label: {
                                teamCell(teamViewModel: team)
                            }
                        }
                    } header: {
                        // Only show game titles if we're showing more than one game
                        if viewModel.shouldShowSectionHeaders {
                            SectionHeader(section.game.title)
                        }
                    } footer: {
                        if viewModel.isLastSection(section) {
                            footer()
                        }
                    }
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private func footer() -> some View {
        if !viewModel.sections.isEmpty {
#if targetEnvironment(macCatalyst)
            Text("Right-click on a team for options")
                .monospacedCaption()
#else
            Text("Tap and hold on a team for options")
                .monospacedCaption()
#endif
        }
    }

    private func emptyState() -> some View {
        Text("No teams")
            .monospacedBody()
    }

    private func teamCell(teamViewModel: TeamViewModel) -> some View {
        TeamCell(team: teamViewModel.team, game: teamViewModel.game)
            .contextMenu {
                Button {
                    viewModel.exportTeam(teamViewModel.team)
                    isShowingPokepasteExport.toggle()
                } label: {
                    Label("Export PokéPaste", image: "share")
                }
                Button(role: .destructive) {
                    currentDeletingTeam = teamViewModel
                    isShowingDeleteTeam.toggle()
                } label: {
                    Label("Delete", image: "trash")
                }
            }
            .alert("Copied to clipboard!", isPresented: $isShowingPokepasteExport) {
                Button("Dismiss", action: { })
            } message: {
                Text("Your team has been exported to the PokéPaste format and copied to the clipboard.")
            }
//            .overlay(alignment: .topTrailing) {
//                DeleteButton {
//                    currentDeletingTeam = teamViewModel
//                    isShowingDeleteTeam.toggle()
//                }
//                .opacity(editMode?.wrappedValue.isEditing == true ? 1.0 : 0.0)
//                .animation(.default, value: editMode?.wrappedValue)
//            }
    }

    @ViewBuilder
    private func selectGame() -> some View {
        ForEach(Game.allGamesNewestFirst) { game in
            Button(game.title) {
                withAnimation {
                    viewModel.addNewTeam(for: game)
                }
            }
        }
        Button("Cancel", role: .cancel) { }
    }

    private func handleURL(url: URL) {
        debugPrint("TeamList URL received: \(url)")
    }

}

struct TeamList_Previews: PreviewProvider {
    static var previews: some View {
        TeamList(
            game: .sword,
            viewFactory: MockTeamViewFactory()
        )
    }
}
