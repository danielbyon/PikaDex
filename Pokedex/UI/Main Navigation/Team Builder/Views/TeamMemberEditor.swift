//
//  TeamMemberEditor.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/11/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct TeamMemberEditor: View {

    @EnvironmentObject var appContext: AppContext
    @ObservedObject var viewModel: TeamMemberViewModel
    @State private var isShowingSelectPokemon = false
    @State private var isShowingSelectMove1 = false
    @State private var isShowingSelectMove2 = false
    @State private var isShowingSelectMove3 = false
    @State private var isShowingSelectMove4 = false
    @State private var isShowingSelectAbility = false
    @State private var isShowingSelectItem = false
    @State private var isShowingSelectNature = false
    @State private var isShowingSelectHPIV = false
    @State private var isShowingSelectAttackIV = false
    @State private var isShowingSelectDefenseIV = false
    @State private var isShowingSelectSpecialAttackIV = false
    @State private var isShowingSelectSpecialDefenseIV = false
    @State private var isShowingSelectSpeedIV = false
    @State private var isShowingSelectHPEV = false
    @State private var isShowingSelectAttackEV = false
    @State private var isShowingSelectDefenseEV = false
    @State private var isShowingSelectSpecialAttackEV = false
    @State private var isShowingSelectSpecialDefenseEV = false
    @State private var isShowingSelectSpeedEV = false

    var body: some View {
        Form {
            Section(header: SectionHeader("Pokémon")) {
                NavigationLink(destination: PokemonDetail(pokemon: viewModel.pokemonForm.pokemon, game: appContext.currentGame, formIndex: viewModel.pokemonForm.formIndex)) {
                    PokemonFormCell(form: viewModel.pokemonForm, game: appContext.currentGame)
                }
            }

            Section {
                TextField("Nickname", text: $viewModel.nickname)
                    .monospacedBody()
                    .avoidKeyboard()
                TeamMemberLevel(level: $viewModel.level)

                NavigationLink(destination: SelectAbility(form: viewModel.pokemonForm, game: appContext.currentGame, onSelect: { ability in
                    self.viewModel.ability = ability
                    self.isShowingSelectAbility = false
                }), isActive: $isShowingSelectAbility) {
                    HStack {
                        Text("Ability")
                            .monospacedBody()
                        Spacer()
                        Text(viewModel.ability.name)
                    }
                    .monospacedBody()
                    .contentShape(Rectangle())
                }

                NavigationLink(destination: SelectItem(game: appContext.currentGame, onSelect: { item in
                    self.viewModel.heldItem = item
                    self.isShowingSelectItem = false
                }), isActive: $isShowingSelectItem) {
                    if let heldItem = viewModel.heldItem {
                        HStack {
                            Text("Held Item")
                                .monospacedBody()
                            Spacer()
                            ItemCell(item: heldItem)
                        }
                        .contentShape(Rectangle())
                    } else {
                        Text("Select Item")
                            .monospacedBody()
                    }
                }

                NavigationLink(destination: SelectNature(onSelect: { nature in
                    self.viewModel.nature = nature
                    self.isShowingSelectNature = false
                }), isActive: $isShowingSelectNature) {
                    HStack {
                        Text("Nature")
                        Spacer()
                        Text(viewModel.nature.name)
                    }
                    .monospacedBody()
                    .contentShape(Rectangle())
                }

                Picker("Happiness", selection: $viewModel.happiness) {
                    ForEach(0..<256) {
                        Text("\($0)")
                            .monospacedBody()
                    }
                }

                SegmentedControl(selectedSegment: $viewModel.gender)
                Picker("Shiny", selection: $viewModel.isShiny) {
                    Text("Shiny")
                        .tag("Shiny")
                    Text("Not Shiny")
                        .tag("Not Shiny")
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            Section(header: SectionHeader("Moves")) {
                NavigationLink(destination: SelectTeamMemberMove(pokemonForm: viewModel.pokemonForm, game: appContext.currentGame, onSelect: { move in
                    self.viewModel.move1 = move
                    self.dismissSelectMove()
                }), isActive: $isShowingSelectMove1) {
                    if let move1 = viewModel.move1 {
                        MoveCell(move: move1, game: appContext.currentGame)
                    } else {
                        makeSelectMoveCell(number: 1)
                    }
                }
                NavigationLink(destination: SelectTeamMemberMove(pokemonForm: viewModel.pokemonForm, game: appContext.currentGame, onSelect: { move in
                    self.viewModel.move2 = move
                    self.dismissSelectMove()
                }), isActive: $isShowingSelectMove2) {
                    if let move2 = viewModel.move2 {
                        MoveCell(move: move2, game: appContext.currentGame)
                    } else {
                        makeSelectMoveCell(number: 2)
                    }
                }
                NavigationLink(destination: SelectTeamMemberMove(pokemonForm: viewModel.pokemonForm, game: appContext.currentGame, onSelect: { move in
                    self.viewModel.move3 = move
                    self.dismissSelectMove()
                }), isActive: $isShowingSelectMove3) {
                    if let move3 = viewModel.move3 {
                        MoveCell(move: move3, game: appContext.currentGame)
                    } else {
                        makeSelectMoveCell(number: 3)
                    }
                }
                NavigationLink(destination: SelectTeamMemberMove(pokemonForm: viewModel.pokemonForm, game: appContext.currentGame, onSelect: { move in
                    self.viewModel.move4 = move
                    self.dismissSelectMove()
                }), isActive: $isShowingSelectMove4) {
                    if let move4 = viewModel.move4 {
                        MoveCell(move: move4, game: appContext.currentGame)
                    } else {
                        makeSelectMoveCell(number: 4)
                    }
                }
            }

            Group {
                makeStatSection(
                    title: "HP",
                    value: viewModel.baseHP,
                    ivRange: viewModel.ivRange,
                    evRange: viewModel.remainingEVRange(forStatType: .hp),
                    iv: $viewModel.hpIV,
                    ev: $viewModel.hpEV,
                    showIV: $isShowingSelectHPIV,
                    showEV: $isShowingSelectHPEV)

                makeStatSection(
                    title: "Attack",
                    value: viewModel.baseAttack,
                    ivRange: viewModel.ivRange,
                    evRange: viewModel.remainingEVRange(forStatType: .attack),
                    iv: $viewModel.attackIV,
                    ev: $viewModel.attackEV,
                    showIV: $isShowingSelectAttackIV,
                    showEV: $isShowingSelectAttackEV)

                makeStatSection(
                    title: "Defense",
                    value: viewModel.baseDefense,
                    ivRange: viewModel.ivRange,
                    evRange: viewModel.remainingEVRange(forStatType: .defense),
                    iv: $viewModel.defenseIV,
                    ev: $viewModel.defenseEV,
                    showIV: $isShowingSelectDefenseIV,
                    showEV: $isShowingSelectDefenseEV)

                if appContext.currentGame.generation > 2 {
                    makeStatSection(
                        title: "Special Attack",
                        value: viewModel.baseSpecialAttack,
                        ivRange: viewModel.ivRange,
                        evRange: viewModel.remainingEVRange(forStatType: .specialAttack),
                        iv: $viewModel.specialAttackIV,
                        ev: $viewModel.specialAttackEV,
                        showIV: $isShowingSelectSpecialAttackIV,
                        showEV: $isShowingSelectSpecialAttackEV)

                    makeStatSection(
                        title: "Special Defense",
                        value: viewModel.baseSpecialDefense,
                        ivRange: viewModel.ivRange,
                        evRange: viewModel.remainingEVRange(forStatType: .specialDefense),
                        iv: $viewModel.specialDefenseIV,
                        ev: $viewModel.specialDefenseEV,
                        showIV: $isShowingSelectSpecialDefenseIV,
                        showEV: $isShowingSelectSpecialDefenseEV)
                }

                makeStatSection(
                    title: "Speed",
                    value: viewModel.baseSpeed,
                    ivRange: viewModel.ivRange,
                    evRange: viewModel.remainingEVRange(forStatType: .speed),
                    iv: $viewModel.speedIV,
                    ev: $viewModel.speedEV,
                    showIV: $isShowingSelectSpeedIV,
                    showEV: $isShowingSelectSpeedEV)

                if appContext.currentGame.generation < 3 {
                    makeStatSection(
                        title: "Special",
                        value: viewModel.baseSpecialAttack,
                        ivRange: viewModel.ivRange,
                        evRange: viewModel.remainingEVRange(forStatType: .specialAttack),
                        iv: $viewModel.specialAttackIV,
                        ev: $viewModel.specialAttackEV,
                        showIV: $isShowingSelectSpecialAttackIV,
                        showEV: $isShowingSelectSpecialAttackEV)

                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Team Member")
    }

    private func makeSelectMoveCell(number: Int) -> some View {
        Text("Select Move \(number)")
            .monospacedBody()
    }

    private func makeStatSection(title: String, value: Int, ivRange: Range<Int>, evRange: Range<Int>, iv: Binding<Int>, ev: Binding<Int>, showIV: Binding<Bool>, showEV: Binding<Bool>) -> some View {
        Section(header: SectionHeader(title)) {
            HStack {
                Text("Base value:")
                Spacer()
                Text("\(value)")
            }
            .monospacedBody()

            NavigationLink(destination: SelectValue(range: ivRange, onSelect: { value in
                iv.wrappedValue = value
                showIV.wrappedValue = false
            }), isActive: showIV) {
                StatValueCell(title: "IV", value: iv.wrappedValue)
            }

            NavigationLink(destination: SelectValue(range: evRange, onSelect: { value in
                ev.wrappedValue = value
                showEV.wrappedValue = false
            }), isActive: showEV) {
                StatValueCell(title: "EV", value: ev.wrappedValue)
            }
        }
    }

    private func dismissSelectMove() {
        isShowingSelectMove1 = false
        isShowingSelectMove2 = false
        isShowingSelectMove3 = false
        isShowingSelectMove4 = false
    }

}

struct TeamMemberEditor_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TeamMemberEditor(viewModel: .init(teamMember: .init(
                pokemon: "Charizard",
                formName: "Charizard",
                nickname: "",
                level: 100,
                hp: .init(baseValue: 78, ev: 0, iv: 0),
                attack: .init(baseValue: 84, ev: 0, iv: 0),
                defense: .init(baseValue: 78, ev: 0, iv: 0),
                specialAttack: .init(baseValue: 109, ev: 0, iv: 0),
                specialDefense: .init(baseValue: 85, ev: 0, iv: 0),
                speed: .init(baseValue: 100, ev: 0, iv: 0),
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
    }
}

private struct TeamMemberLevel: View {

    @Binding var level: Double

    var body: some View {
        HStack {
            Text("Level")
                .monospacedBody()
            Slider(value: $level, in: 1...100, step: 1, onEditingChanged: {_ in })
            UIKitStepper(value: $level, step: 1.0, minimumValue: 1.0, maximumValue: 100.0)
            Text("   ")
                .monospacedBody()
                .overlay(
                    Text(NumberFormatter.twoDigit.string(from: NSNumber(value: level)) ?? "")
                        .monospacedBody())
        }
    }

}

private struct StatValueCell: View {

    let title: String
    let value: Int

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text("\(value)")
        }
        .monospacedBody()
        .contentShape(Rectangle())
    }
}
