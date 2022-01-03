//
//  TeamMemberEditor.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/11/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct TeamMemberEditor: View {

    @EnvironmentObject var settings: AppSettings
    @ObservedObject var viewModel: TeamMemberViewModel

    var body: some View {
        Form {
            Section(header: SectionHeader("Pokémon")) {
                NavigationLink {
                    PokemonDetail(
                        pokemon: viewModel.pokemonForm.pokemon,
                        game: viewModel.game,
                        formIndex: viewModel.pokemonForm.formIndex
                    )
                } label: {
                    PokemonFormCell(form: viewModel.pokemonForm, game: viewModel.game)
                }
            }

            Section {
                TextField("Nickname", text: $viewModel.nickname)
                    .monospacedBody()
                TeamMemberLevel(level: $viewModel.level)
                
                if settings.currentGame.hasAbilities {
                    NavigationLink {
                        SelectAbility(form: viewModel.pokemonForm, game: viewModel.game) { ability in
                            viewModel.ability = ability
                        }
                    } label: {
                        HStack {
                            Text("Ability")
                                .monospacedBody()
                            Spacer()
                            if let ability = viewModel.ability {
                                Text(ability.name)
                            }
                        }
                        .monospacedBody()
                        .contentShape(Rectangle())
                    }
                }

                NavigationLink {
                    SelectItem(game: viewModel.game) { item in
                        viewModel.heldItem = item
                    }
                } label: {
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

                NavigationLink {
                    SelectNature { nature in
                        viewModel.nature = nature
                    }
                } label: {
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
                        .tag(true)
                    Text("Not Shiny")
                        .tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            Section(header: SectionHeader("Moves")) {
                NavigationLink {
                    SelectTeamMemberMove(pokemonForm: viewModel.pokemonForm, game: viewModel.game) { move in
                        self.viewModel.move1 = move
                    }
                } label: {
                    if let move1 = viewModel.move1 {
                        MoveCell(move: move1, game: viewModel.game)
                    } else {
                        makeSelectMoveCell(number: 1)
                    }
                }

                NavigationLink {
                    SelectTeamMemberMove(pokemonForm: viewModel.pokemonForm, game: viewModel.game) { move in
                        self.viewModel.move2 = move
                    }
                } label: {
                    if let move2 = viewModel.move2 {
                        MoveCell(move: move2, game: viewModel.game)
                    } else {
                        makeSelectMoveCell(number: 2)
                    }
                }

                NavigationLink {
                    SelectTeamMemberMove(pokemonForm: viewModel.pokemonForm, game: viewModel.game) { move in
                        self.viewModel.move3 = move
                    }
                } label: {
                    if let move3 = viewModel.move3 {
                        MoveCell(move: move3, game: viewModel.game)
                    } else {
                        makeSelectMoveCell(number: 3)
                    }
                }

                NavigationLink {
                    SelectTeamMemberMove(pokemonForm: viewModel.pokemonForm, game: viewModel.game) { move in
                        self.viewModel.move4 = move
                    }
                } label: {
                    if let move4 = viewModel.move4 {
                        MoveCell(move: move4, game: viewModel.game)
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
                    isCalculated: $viewModel.hpCalculated,
                    manualValue: $viewModel.hpValue
                )

                makeStatSection(
                    title: "Attack",
                    value: viewModel.baseAttack,
                    ivRange: viewModel.ivRange,
                    evRange: viewModel.remainingEVRange(forStatType: .attack),
                    iv: $viewModel.attackIV,
                    ev: $viewModel.attackEV,
                    isCalculated: $viewModel.attackCalculated,
                    manualValue: $viewModel.attackValue
                )

                makeStatSection(
                    title: "Defense",
                    value: viewModel.baseDefense,
                    ivRange: viewModel.ivRange,
                    evRange: viewModel.remainingEVRange(forStatType: .defense),
                    iv: $viewModel.defenseIV,
                    ev: $viewModel.defenseEV,
                    isCalculated: $viewModel.defenseCalculated,
                    manualValue: $viewModel.defenseValue
                )

                if settings.currentGame.generation > 2 {
                    makeStatSection(
                        title: "Special Attack",
                        value: viewModel.baseSpecialAttack,
                        ivRange: viewModel.ivRange,
                        evRange: viewModel.remainingEVRange(forStatType: .specialAttack),
                        iv: $viewModel.specialAttackIV,
                        ev: $viewModel.specialAttackEV,
                        isCalculated: $viewModel.specialAttackCalculated,
                        manualValue: $viewModel.specialAttackValue
                    )

                    makeStatSection(
                        title: "Special Defense",
                        value: viewModel.baseSpecialDefense,
                        ivRange: viewModel.ivRange,
                        evRange: viewModel.remainingEVRange(forStatType: .specialDefense),
                        iv: $viewModel.specialDefenseIV,
                        ev: $viewModel.specialDefenseEV,
                        isCalculated: $viewModel.specialDefenseCalculated,
                        manualValue: $viewModel.specialDefenseValue
                    )
                }

                makeStatSection(
                    title: "Speed",
                    value: viewModel.baseSpeed,
                    ivRange: viewModel.ivRange,
                    evRange: viewModel.remainingEVRange(forStatType: .speed),
                    iv: $viewModel.speedIV,
                    ev: $viewModel.speedEV,
                    isCalculated: $viewModel.speedCalculated,
                    manualValue: $viewModel.speedValue
                )

                if settings.currentGame.generation < 3 {
                    makeStatSection(
                        title: "Special",
                        value: viewModel.baseSpecialAttack,
                        ivRange: viewModel.ivRange,
                        evRange: viewModel.remainingEVRange(forStatType: .specialAttack),
                        iv: $viewModel.specialAttackIV,
                        ev: $viewModel.specialAttackEV,
                        isCalculated: $viewModel.specialAttackCalculated,
                        manualValue: $viewModel.specialAttackValue
                    )

                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Team Member")
        .navigation(item: $selectedAbility) { ability in
            AbilityDetail(ability: ability, game: viewModel.game)
        }
    }

    private func makeSelectMoveCell(number: Int) -> some View {
        Text("Select Move \(number)")
            .monospacedBody()
    }

    private func makeStatSection(
        title: String,
        value: Int,
        ivRange: Range<Int>,
        evRange: Range<Int>,
        iv: Binding<Int>,
        ev: Binding<Int>,
        isCalculated: Binding<Bool>,
        manualValue: Binding<Int>
    ) -> some View {
        Section(header: SectionHeader(title)) {
            Picker("", selection: isCalculated) {
                Text("Calculated")
                    .tag(true)
                Text("Manual")
                    .tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())

            if isCalculated.wrappedValue {
                HStack {
                    Text("Base value:")
                    Spacer()
                    Text("\(value)")
                }
                .monospacedBody()

                NavigationLink {
                    SelectValue(range: ivRange) { value in
                        iv.wrappedValue = value
                    }
                } label: {
                    StatValueCell(title: "IV", value: iv.wrappedValue)
                }

                NavigationLink {
                    SelectValue(range: evRange) { value in
                        ev.wrappedValue = value
                    }
                } label: {
                    StatValueCell(title: "EV", value: ev.wrappedValue)
                }
            } else {
                TextField("Value", value: manualValue, formatter: _valueFormatter, prompt: Text("Value"))
            }
        }
    }

}

private let _valueFormatter: Formatter = {
    let formatter = NumberFormatter()
    formatter.maximumFractionDigits = 0
    return formatter
}()

struct TeamMemberEditor_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TeamMemberEditor(viewModel: .init(teamMember: .init(
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
