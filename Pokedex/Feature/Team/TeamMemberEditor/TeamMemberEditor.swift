//
//  TeamMemberEditor.swift
//  
//
//  Created by Daniel Byon on 10/31/22.
//

import PokedexUI
import SwiftUI

struct TeamMemberEditor: View {

    @ObservedObject var viewModel: TeamMemberViewModel

    var body: some View {
        Form {
            Section {
                TextField("Nickname", text: $viewModel.teamMember.nickname)
                    .monospacedBody()
                TeamMemberLevel(level: $viewModel.level)

                if viewModel.game.hasAbilities {
                    NavigationLink {
                        SelectAbility(
                            pokemonForm: viewModel.pokemonForm,
                            game: viewModel.game,
                            currentAbility: viewModel.ability
                        ) { ability in
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
                    SelectItem(
                        game: viewModel.game,
                        currentItem: viewModel.heldItem
                    ) { item in
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
                    SelectNature() { nature in
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

                Picker("Happiness", selection: $viewModel.teamMember.happiness) {
                    ForEach(0..<256) {
                        Text("\($0)")
                            .monospacedBody()
                    }
                }

                SegmentedControl(selectedSegment: $viewModel.teamMember.gender)
                Picker("Shiny", selection: $viewModel.teamMember.isShiny) {
                    Text("shiny")
                        .tag(true)
                    Text("not Shiny")
                        .tag(false)
                }
                .pickerStyle(.segmented)
            }

            Section {
                NavigationLink {
                    SelectTeamMemberMove(
                        pokemonForm: viewModel.pokemonForm,
                        currentMove: viewModel.move1
                    ) { move in
                        viewModel.move1 = move
                    }
                } label: {
                    if let move1 = viewModel.move1 {
                        MoveCell(move: move1)
                    } else {
                        makeSelectMoveCell(number: 1)
                    }
                }

                NavigationLink {
                    SelectTeamMemberMove(
                        pokemonForm: viewModel.pokemonForm,
                        currentMove: viewModel.move2
                    ) { move in
                        viewModel.move2 = move
                    }
                } label: {
                    if let move2 = viewModel.move2 {
                        MoveCell(move: move2)
                    } else {
                        makeSelectMoveCell(number: 2)
                    }
                }

                NavigationLink {
                    SelectTeamMemberMove(
                        pokemonForm: viewModel.pokemonForm,
                        currentMove: viewModel.move3
                    ) { move in
                        viewModel.move3 = move
                    }
                } label: {
                    if let move3 = viewModel.move3 {
                        MoveCell(move: move3)
                    } else {
                        makeSelectMoveCell(number: 3)
                    }
                }

                NavigationLink {
                    SelectTeamMemberMove(
                        pokemonForm: viewModel.pokemonForm,
                        currentMove: viewModel.move4
                    ) { move in
                        viewModel.move4 = move
                    }
                } label: {
                    if let move4 = viewModel.move4 {
                        MoveCell(move: move4)
                    } else {
                        makeSelectMoveCell(number: 4)
                    }
                }
            } header: {
                SectionHeader("Moves")
            }

            Group {
                makeStatSection(
                    title: "HP",
                    value: viewModel.teamMember.hp.baseValue,
                    ivRange: viewModel.ivRange,
                    evRange: viewModel.remainingEVRange(forStatType: .hp),
                    iv: $viewModel.teamMember.hp.iv,
                    ev: $viewModel.teamMember.hp.ev,
                    isCalculated: $viewModel.teamMember.hp.isCalculated,
                    manualValue: $viewModel.teamMember.hp.value
                )

                makeStatSection(
                    title: "Attack",
                    value: viewModel.teamMember.attack.baseValue,
                    ivRange: viewModel.ivRange,
                    evRange: viewModel.remainingEVRange(forStatType: .attack),
                    iv: $viewModel.teamMember.attack.iv,
                    ev: $viewModel.teamMember.attack.ev,
                    isCalculated: $viewModel.teamMember.attack.isCalculated,
                    manualValue: $viewModel.teamMember.attack.value
                )

                makeStatSection(
                    title: "Defense",
                    value: viewModel.teamMember.defense.baseValue,
                    ivRange: viewModel.ivRange,
                    evRange: viewModel.remainingEVRange(forStatType: .defense),
                    iv: $viewModel.teamMember.defense.iv,
                    ev: $viewModel.teamMember.defense.ev,
                    isCalculated: $viewModel.teamMember.defense.isCalculated,
                    manualValue: $viewModel.teamMember.defense.value
                )

                    makeStatSection(
                        title: "Special Attack",
                        value: viewModel.teamMember.specialAttack.baseValue,
                        ivRange: viewModel.ivRange,
                        evRange: viewModel.remainingEVRange(forStatType: .specialAttack),
                        iv: $viewModel.teamMember.specialAttack.iv,
                        ev: $viewModel.teamMember.specialAttack.ev,
                        isCalculated: $viewModel.teamMember.specialAttack.isCalculated,
                        manualValue: $viewModel.teamMember.specialAttack.value
                    )

                if viewModel.game.generation > 2 {
                    makeStatSection(
                        title: "Special Defense",
                        value: viewModel.teamMember.specialDefense.baseValue,
                        ivRange: viewModel.ivRange,
                        evRange: viewModel.remainingEVRange(forStatType: .specialDefense),
                        iv: $viewModel.teamMember.specialDefense.iv,
                        ev: $viewModel.teamMember.specialDefense.ev,
                        isCalculated: $viewModel.teamMember.specialDefense.isCalculated,
                        manualValue: $viewModel.teamMember.specialDefense.value
                    )
                }

                makeStatSection(
                    title: "Speed",
                    value: viewModel.teamMember.speed.baseValue,
                    ivRange: viewModel.ivRange,
                    evRange: viewModel.remainingEVRange(forStatType: .speed),
                    iv: $viewModel.teamMember.speed.iv,
                    ev: $viewModel.teamMember.speed.ev,
                    isCalculated: $viewModel.teamMember.speed.isCalculated,
                    manualValue: $viewModel.teamMember.speed.value
                )

                if viewModel.game.generation < 3 {
                    makeStatSection(
                        title: "Special",
                        value: viewModel.teamMember.specialAttack.baseValue,
                        ivRange: viewModel.ivRange,
                        evRange: viewModel.remainingEVRange(forStatType: .specialAttack),
                        iv: $viewModel.teamMember.specialAttack.iv,
                        ev: $viewModel.teamMember.specialAttack.ev,
                        isCalculated: $viewModel.teamMember.specialAttack.isCalculated,
                        manualValue: $viewModel.teamMember.specialAttack.value
                    )

                }
            }
        }
        .listStyle(.grouped)
        .navigationTitle("Edit Team Member")
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
        Section {
            Picker("", selection: isCalculated) {
                Text("Calculated")
                    .tag(true)
                Text("Manual")
                    .tag(false)
            }
            .pickerStyle(.segmented)

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
        } header: {
            SectionHeader(title)
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
        TeamMemberEditor(
            viewModel: .init(
                teamMember: Team.stub1.members[0],
                team: .stub1
            )
        )
    }
}

private struct TeamMemberLevel: View {

    @Binding var level: Double

    var body: some View {
        HStack {
            Text("Level")
                .monospacedBody()
            Slider(value: $level, in: 1...100, step: 1, onEditingChanged: {_ in })
//            UIKitStepper(value: $level, step: 1.0, minimumValue: 1.0, maximumValue: 100.0)
            Stepper(value: $level, in: 1.0...100.0, step: 1.0) {
                EmptyView()
            }
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
