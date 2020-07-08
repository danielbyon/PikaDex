//
//  TeamBuilder.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/22/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct TeamBuilder: View {

    @EnvironmentObject var appContext: AppContext
    @ObservedObject var viewModel: TeamBuilderViewModel
    @State private var currentEditingTeam: TeamViewModel?

    var body: some View {
        Group {
            if viewModel.teams.isEmpty {
                Text("No teams")
                    .monospacedBody()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24.0) {
                        ForEach(viewModel.teams) { team in
                            Button(action: {
                                self.currentEditingTeam = team
                            }) {
                                TeamCell(team: team)
                                    .contextMenu(ContextMenu {
                                        Button(action: {
                                            self.viewModel.deleteTeam(team)
                                        }) {
                                            Text("Delete")
                                        }
                                    })
                            }
                        }

                        if !viewModel.teams.isEmpty {
                            #if targetEnvironment(macCatalyst)
                            Text("Right-click on a team to remove")
                                .monospacedCaption()
                            #else
                            Text("Tap and hold on a team to remove")
                                .monospacedCaption()
                            #endif
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitle("Teams", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            let newTeam = self.viewModel.addNewTeam()
            self.currentEditingTeam = newTeam
        }) {
            Image(systemName: "plus")
                .padding([.leading, .top, .bottom])
        })
            .sheet(item: self.$currentEditingTeam) { viewModel in
                NavigationView {
                    TeamEditor(viewModel: viewModel)
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .injectDependencies()
        }
    }

}

struct TeamBuilder_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                TeamBuilder(viewModel: .init(game: .sword))
            }
            NavigationView {
                TeamBuilder(viewModel: .init(game: .sword))
            }
            .colorScheme(.dark)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .injectDependencies()
    }
}

private struct TeamCell: View {

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @ObservedObject var team: TeamViewModel

    private var emptySlots: [Marker] { Array([.init(index: 0), .init(index: 1), .init(index: 2), .init(index: 3), .init(index: 4), .init(index: 5)].dropFirst(team.members.count)) }

    var body: some View {
        Card {
            // TODO: 1.0 release
//            VStack(alignment: .leading) {
                HStack {
                    Text(team.name)
                        .monospacedTitle()
                        .bold()
                    Spacer()
                }
            // TODO: 1.0 release
//                HStack {
//                    Card(backgroundColor: Color(UIColor.systemGray3)) {
//                        HStack(spacing: 0) {
//                            ForEach(team.members) { member in
//                                if !self.team.isFirstMember(member) {
//                                    Spacer(minLength: 0)
//                                }
//                                PokemonFormSprite(form: member.pokemonForm)
//                            }
//                            if team.members.count < 6 {
//                                ForEach(emptySlots) { i in
//                                    if (self.team.members.count > 0 || i.index > 0) {
//                                        Spacer(minLength: 0)
//                                    }
//                                    Rectangle()
//                                        .fill(Color.clear)
//                                        .frame(width: 40, height: 40.0)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
        }
    }
}

private struct Marker: Identifiable {

    let index: Int
    let id = UUID().uuidString

}
