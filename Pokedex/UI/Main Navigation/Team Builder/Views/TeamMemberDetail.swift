//
//  TeamMemberDetail.swift
//  Pokedex
//
//  Created by Daniel Byon on 1/2/22.
//  Copyright © 2022 Daniel Byon. All rights reserved.
//

import SwiftUI

struct TeamMemberDetail: View {

    @ObservedObject var member: TeamMemberViewModel
    @State private var isShowingEditScreen = false

    private var moves: [Move] {
        [member.move1, member.move2, member.move3, member.move4].compactMap { $0 }
    }

    var body: some View {
        List {
            Section {
                NavigationLink {
                    PokemonDetail(
                        pokemon: member.pokemonForm.pokemon,
                        game: member.game,
                        formIndex: member.pokemonForm.formIndex
                    )
                } label: {
                    TeamMemberCell(member: member)
                }
            }

            Section(header: SectionHeader("Ability")) {
                if let ability = member.ability {
                    NavigationLink {
                        AbilityDetail(ability: ability, game: member.game)
                    } label: {
                        Text(ability.name)
                    }
                } else {
                    Text("No ability selected")
                }
            }

            Section(header: SectionHeader("Moves")) {
                if moves.isEmpty {
                    Text("No moves")
                } else {
                    ForEach(moves) { move in
                        NavigationLink {
                            MoveDetail(move: move, game: member.game)
                        } label: {
                            Text(move.name)
                        }
                    }
                }
            }
        }
        .navigationTitle(member.pokemonForm.name)
        .listStyle(.grouped)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button("Edit") {
                    isShowingEditScreen.toggle()
                }
            }
        }
        .sheet(isPresented: $isShowingEditScreen, onDismiss: nil) {
            NavigationView {
                TeamMemberEditor(viewModel: member)
                    .toolbar {
                        ToolbarItemGroup(placement: .primaryAction) {
                            DoneButton {
                                isShowingEditScreen = false
                            }
                        }
                    }
            }
        }
    }

}

struct TeamMemberDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
        TeamMemberDetail(member: .init(teamMember: .init(
            pokemon: "Charizard",
            formName: "Charizard",
            nickname: "",
            level: 100,
            hp: .init(baseValue: 78, ev: 0, iv: 0, isCalculated: true, value: 0),
            attack: .init(baseValue: 84, ev: 0, iv: 0, isCalculated: true, value: 0),
            defense: .init(baseValue: 78, ev: 0, iv: 0, isCalculated: true, value: 0),
            specialAttack: .init(baseValue: 109, ev: 0, iv: 0, isCalculated: true, value: 0),
            specialDefense: .init(baseValue: 85, ev: 0, iv: 0, isCalculated: true, value: 0),
            speed: .init(baseValue: 100, ev: 0, iv: 0, isCalculated: true, value: 0),
            move1: "Fire Blast",
            move2: "Fly",
            move3: "Hyper Beam",
            move4: nil,
            nature: Nature.bold.name,
            ability: "Blaze",
            heldItem: nil,
            happiness: 255,
            isShiny: false,
            gender: .male,
            game: .sword,
            internalID: UUID())))
        }
        .injectDependencies()
//        .preferredColorScheme(.dark)
    }
}
