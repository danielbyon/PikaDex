//
//  TeamEditor.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/11/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI
import Combine

struct TeamEditor: View {

    let game: Game

    @Environment(\.editMode) var editMode
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @ObservedObject var viewModel: TeamViewModel
    @State private var deletingMember: TeamMemberViewModel?
    @State private var replacingMember: TeamMemberViewModel?
    @State private var isShowingDeleteConfirmation = false

    private var numberOfColumns: Int { horizontalSizeClass == .regular ? 2 : 1 }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: .init(), count: numberOfColumns), alignment: .leading, spacing: 24.0) {
                Section {
                    Card {
                        TextField("Name", text: $viewModel.name)
                            .monospacedBody()
                    }
                }

                Section(footer: footer()) {
                    ForEach(viewModel.members) { member in
                        NavigationLink {
                            TeamMemberDetail(member: member)
                        } label: {
                            teamMemberCell(member: member)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(viewModel.name)
        .confirmationDialog(Text("Delete team member?"), isPresented: $isShowingDeleteConfirmation, presenting: deletingMember) { member in
            Button(role: .destructive) {
                withAnimation {
                    viewModel.deleteMember(member)
                }
            } label: {
                Text("Delete")
            }
            Button(role: .cancel, action: {}) {
                Text("Cancel")
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                EditButton()
                NavigationLink {
                    SelectPokemonForm(game: game, onSelect: addMember)
                } label: {
                    Image(systemName: "plus")
                }
                .disabled(viewModel.members.count >= 6)
            }
        }
        .navigation(item: $replacingMember) { member in
            SelectPokemonForm(game: game) { replacement in
                viewModel.replaceMember(member, with: replacement)
            }
        }
    }

    @ViewBuilder
    private func footer() -> some View {
        if !viewModel.members.isEmpty {
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
        TeamMemberCell(member: member)
            .contextMenu {
                Button {
                    replacingMember = member
                } label: {
                    Label("Replace", systemImage: "arrow.triangle.2.circlepath")
                }
                Button("Delete", role: .destructive) {
                    isShowingDeleteConfirmation = true
                    deletingMember = member
                }
            }
            .overlay(
                DeleteButton {
                    isShowingDeleteConfirmation = true
                    deletingMember = member
                }.opacity(editMode?.wrappedValue.isEditing == true ? 1.0 : 0.0),
                alignment: .topTrailing
            )
    }

    private func addMember(_ pokemonForm: PokemonForm) {
        guard viewModel.members.count < 6 else { assertionFailure("Attempting to add a member to a full team!"); return }
        viewModel.addMember(pokemonForm, game: game)
    }

    private func deleteMember(_ member: TeamMemberViewModel) {
        withAnimation {
            viewModel.deleteMember(member)
        }
    }

}

struct AddTeam_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TeamEditor(game: .sword, viewModel: .init(name: "Test Team", members: [], internalID: UUID()))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .injectDependencies()
    }
}
