//
//  TeamView.swift
//  
//
//  Created by Daniel Byon on 10/26/22.
//

import PokedexUI
import SwiftUI

public struct TeamView: View {

    // MARK: Properties

    @Environment(\.pokedexDataStore) var dataStore
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
            }
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
                Section {
                    Card {
                        TextField("Name", text: viewModel.name)
                            .monospacedBody()
                    }
                }

                Section {
                    ForEach(viewModel.members, id: \.teamMember.id) { member in
                        NavigationLink(value: Route.content(.teamMember(member))) {
                            teamMemberCell(member: member)
                        }
                    }

                    if viewModel.canAddMembers {
                        NavigationLink(value: Route.battleAssistant(.selectPokemon(
                            viewModel.game,
                            onSelect: viewModel.addMember
                        ))) {
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
        }
    }

}

struct TeamView_Previews: PreviewProvider {
    static var previews: some View {
        TeamView(
            viewModel: .init(team: .stub1, game: .sword)
        )
    }
}
