//
//  TeamView.swift
//  
//
//  Created by Daniel Byon on 10/26/22.
//

import PokedexUI
import SwiftUI

public struct TeamView<ViewFactory: TeamViewFactory>: View {

    // MARK: Properties

    let viewFactory: ViewFactory

    @Environment(\.pokedexDataStore) var dataStore
//    @Environment(\.editMode) var editMode
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @ObservedObject var viewModel: TeamViewModel
    @State private var currentDeletingMember: TeamMember?
    @State private var isShowingDeleteMember = false

    private var numberOfColumns: Int { horizontalSizeClass == .regular ? 2 : 1 }
    
    public var body: some View {
        content(team: viewModel.team)
            .navigationTitle(viewModel.team.name)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    HomeButton()
                }
//                ToolbarItemGroup(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
            }
    }

    // MARK: Init

    public init(
//        team: Team,
//        game: Game,
        viewModel: TeamViewModel,
        viewFactory: ViewFactory
    ) {
//        self.team = team
//        self.game = game
        self.viewModel = viewModel
        self.viewFactory = viewFactory
    }

    // MARK: Private Functions

    @ViewBuilder
    private func content(team: Team) -> some View {
        ScrollView {
            LazyVGrid(
                columns: Array(repeating: .init(), count: numberOfColumns),
                alignment: .leading,
                spacing: 24.0
            ) {
//                Section {
//                    Card {
//                        TextField("Name", text: viewModel.name)
//                            .monospacedBody()
//                    }
//                }

                Section {
                    ForEach(viewModel.members, id: \.teamMember.id) { member in
                        NavigationLink {
                            TeamMemberView(
                                viewModel: member,
                                viewFactory: viewFactory
                            )
                        } label: {
                            teamMemberCell(member: member)
                        }

//                        NavigationLink(value: Route.content(.teamMember(member, team: team, game: game))) {
//                            teamMemberCell(member: member)
//                        }
                    }

                    if viewModel.canAddMembers {
                        NavigationLink {
                            viewFactory.makeSelectPokemonFormView(game: viewModel.game)
                                .onSelectPokemonForm { pokemonForm in
                                    withAnimation {
                                        viewModel.addMember(pokemonForm)
                                    }
                                }
                        } label: {
                            Card {
                                Label("Add Team Member", systemImage: "plus")
                            }
                        }
                    }
                } footer: {
                    footer(team: team)
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    private func footer(team: Team) -> some View {
        if !team.members.isEmpty {
#if targetEnvironment(macCatalyst)
            Text("Right-click on a Pokémon for options")
                .monospacedCaption()
#else
            Text("Tap and hold on a Pokémon for options")
                .monospacedCaption()
#endif
        }
    }

    private func teamMemberCell(member: TeamMemberViewModel) -> some View {
        ZStack(alignment: .topTrailing) {
            TeamMemberCell(viewModel: member)
//                .overlay(alignment: .topTrailing) {
//
//                }
                .contextMenu {
                    Button(role: .destructive) {
                        currentDeletingMember = member.teamMember
                        isShowingDeleteMember.toggle()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .confirmationDialog(
                    "Delete team member?",
                    isPresented: $isShowingDeleteMember,
                    presenting: currentDeletingMember
                ) { member in
                    Button("Delete", role: .destructive) {
                        withAnimation {
                            viewModel.removeMember(member)
                        }
                    }
                }

//            DeleteButton {
//                currentDeletingMember = member.teamMember
//                isShowingDeleteMember.toggle()
//            }
//            .opacity(editMode?.wrappedValue.isEditing == true ? 1.0 : 0.0)
//            .animation(.default, value: editMode?.wrappedValue)
        }
    }

}

struct TeamView_Previews: PreviewProvider {
    static var previews: some View {
        TeamView(
            viewModel: .init(team: .stub1, game: .sword),
            viewFactory: MockTeamViewFactory()
        )
    }
}
