//
//  TeamMemberView.swift
//  
//
//  Created by Daniel Byon on 10/30/22.
//

import PokedexUI
import SwiftUI

public struct TeamMemberView: View {

    @ObservedObject var viewModel: TeamMemberViewModel
    @State private var isShowingEditMode = false

    public var body: some View {
        List {
            Section {
                NavigationLink(value: Route.content(.pokemonDetailForm(viewModel.pokemonForm, pokedex: .national))) {
                    TeamMemberCell(viewModel: viewModel)
                }
            }

            Section {
                if let ability = viewModel.ability {
                    NavigationLink(value: Route.content(.ability(
                        ability,
                        game: viewModel.teamMember.game,
                        pokedex: .national
                    ))) {
                        Text(ability.name)
                    }
                } else {
                    Text("No ability selected")
                }
            } header: {
                SectionHeader("Ability")
            }

            Section {
                if viewModel.moves.isEmpty {
                    Text("No moves")
                } else {
                    ForEach(viewModel.moves, id: \.self) { move in
                        NavigationLink(value: Route.content(.move(move))) {
                            Text(move.name)
                        }
                    }
                }
            } header: {
                SectionHeader("Moves")
            }
        }
        .navigationTitle(viewModel.pokemonForm.name)
        .listStyle(.grouped)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                HomeButton()
            }
            ToolbarItemGroup(placement: .primaryAction) {
                NavigationLink("Edit") {
                    TeamMemberEditor(viewModel: viewModel)
                }
            }
        }
    }

}

struct TeamMemberView_Previews: PreviewProvider {
    static var previews: some View {
        TeamMemberView(
            viewModel: .init(
                teamMember: Team.stub1.members[0],
                team: .stub1
            )
        )
    }
}
