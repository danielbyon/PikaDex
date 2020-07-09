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

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appContext: AppContext
    @ObservedObject var viewModel: TeamViewModel
    @State private var isShowingAddMember = false

    private var numberOfColumns: Int { horizontalSizeClass == .regular ? 2 : 1 }
    private var numberOfRows: Int {
        Int(Double((Double(self.viewModel.members.count) / Double(self.numberOfColumns))).rounded(.up))
    }

    private var addPokemonCell: some View {
        NavigationLink(destination: SelectPokemonForm(game: appContext.currentGame, onSelect: { pokemonForm in
            self.viewModel.addMember(pokemonForm, game: self.appContext.currentGame)
            self.isShowingAddMember = false
        }).injectDependencies(), isActive: $isShowingAddMember) {
            AddTeamMemberCell()
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24.0) {
                Card {
                    TextField("Name", text: $viewModel.name)
                        .monospacedBody()
                        .avoidKeyboard()
                }

                ForEach(viewModel.members) { member in
                    NavigationLink(destination: TeamMemberEditor(viewModel: member).injectDependencies()) {
                        TeamMemberCell(member: member)
                            .contextMenu(ContextMenu {
                                Button(action: {
                                    self.viewModel.deleteMember(member)
                                }) {
                                    Text("Delete")
                                }
                            })
                    }
                }

                if viewModel.members.count < 6 {
                    NavigationLink(destination: SelectPokemonForm(game: appContext.currentGame, onSelect: { pokemonForm in
                        self.viewModel.addMember(pokemonForm, game: self.appContext.currentGame)
                        self.isShowingAddMember = false
                    }).injectDependencies(), isActive: $isShowingAddMember) {
                        AddTeamMemberCell()
                    }
                }

                if !viewModel.members.isEmpty {
                    #if targetEnvironment(macCatalyst)
                    Text("Right-click on a Pokémon to remove")
                        .monospacedCaption()
                    #else
                    Text("Tap and hold on a Pokémon to remove")
                        .monospacedCaption()
                    #endif
                }
            }
            .padding()
        }
        .navigationBarTitle(Text(viewModel.name), displayMode: .inline)
        .navigationBarItems(leading: DoneButton(isTrailing: false, action: self.dismiss))
    }

    init(viewModel: TeamViewModel) {
        self.viewModel = viewModel
    }

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

}

struct AddTeam_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TeamEditor(viewModel: .init(name: "Test Team", members: [], internalID: UUID()))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .injectDependencies()
    }
}

private struct Factoid: View {

    let title: String
    let value: String

    var body: some View {
        VStack {
            Text(value)
                .monospacedBody()
            Text(title)
                .monospacedCaption()
        }
    }

}

private struct TeamMemberCell: View {

    @ObservedObject var member: TeamMemberViewModel

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 16.0) {
                TeamMemberFormInfo(form: member.pokemonForm, gender: member.gender)
                TeamMemberMoves(member: member)
                TeamMemberStats(member: member)
                TeamMemberFactoids(member: member)
            }
        }
    }

}

private struct AddTeamMemberCell: View {

    var body: some View {
        Card {
            VStack {
                Spacer(minLength: 0)
            HStack {
                Image(systemName: "plus.circle")
                Text("Add Pokémon")
                    .monospacedBody()
                Spacer()
            }
                Spacer(minLength: 0)
            }
        }
    }

}

private struct TeamMemberFormInfo: View {

    let form: PokemonForm
    let gender: Gender

    private var resolvedName: String {
        var retVal = form.pokemon.name
        if let abbreviation = gender.abbreviation {
            retVal += " (\(abbreviation))"
        }
        return retVal
    }
    private var shouldShowFormName: Bool { form.name != form.pokemon.name }

    var body: some View {
        HStack {
            PokemonFormSprite(form: form)
            VStack(alignment: .leading) {
                Text(resolvedName)
                    .monospacedBody()
                    .fixedSize(horizontal: false, vertical: true)
                if shouldShowFormName {
                    Text(form.name)
                        .monospacedCaption()
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer()
            VStack(spacing: 2.0) {
                Badge(pokemonType: form.primaryType, equalWidths: true, isSmall: true)
                if form.secondaryType != nil {
                    Badge(pokemonType: form.secondaryType!, equalWidths: true, isSmall: true)
                }
            }
        }
    }
}

private struct TeamMemberMoves: View {

    @ObservedObject var member: TeamMemberViewModel

    private let emptyMove = "\u{2014}"

    private var noMove: some View {
        HStack {
            Text("\u{2014}")
                .monospacedBody()
            Spacer()
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            if member.move1 != nil {
                MoveCell(move: member.move1!, game: member.game)
            } else {
                noMove
            }
            if member.move2 != nil {
                MoveCell(move: member.move2!, game: member.game)
            } else {
                noMove
            }
            if member.move3 != nil {
                MoveCell(move: member.move3!, game: member.game)
            } else {
                noMove
            }
            if member.move4 != nil {
                MoveCell(move: member.move4!, game: member.game)
            } else {
                noMove
            }
        }
    }

}

private struct TeamMemberStats: View {

    @ObservedObject var member: TeamMemberViewModel

    private var viewModels: [ViewModel] {
        [
            .init(name: "HP", value: member.calculatedHP, iv: member.hpIV, ev: member.hpEV, color: Color(Stats.hpColor)),
            .init(name: "ATK", value: member.calculatedAttack, iv: member.attackIV, ev: member.attackEV, color: Color(Stats.attackColor)),
            .init(name: "DEF", value: member.calculatedDefense, iv: member.defenseIV, ev: member.defenseEV, color: Color(Stats.defenseColor)),
            .init(name: "SPA", value: member.calculatedSpecialAttack, iv: member.specialAttackIV, ev: member.specialAttackEV, color: Color(Stats.specialAttackColor)),
            .init(name: "SDF", value: member.calculatedSpecialDefense, iv: member.specialDefenseIV, ev: member.specialDefenseEV, color: Color(Stats.specialDefenseColor)),
            .init(name: "SPD", value: member.calculatedSpeed, iv: member.speedIV, ev: member.speedEV, color: Color(Stats.speedColor)),
        ]
    }

    struct ViewModel {

        let name: String
        let value: Int
        let iv: Int
        let ev: Int
        let color: Color
        var fraction: Double { Double(value) / Self.maxStatValue }

        static let maxStatValue = 714.0

    }

    var body: some View {
        HStack {
            VStack(alignment: .statAlignment, spacing: 2) {
                ForEach(viewModels) { stat in
                    Text(stat.name + ":")
                        .alignmentGuide(.statAlignment, computeValue: { d in d[.trailing] })
                        .monospacedBody()
                }
            }
            .layoutPriority(1)

            VStack(alignment: .trailing, spacing: 2) {
                ForEach(viewModels) { stat in
                    Text("\(stat.value)")
                        .monospacedBody()
                }
            }
            .layoutPriority(1)

            VStack(alignment: .leading, spacing: 2) {
                ForEach(viewModels) { stat in
                    Text("(\(stat.iv)/\(stat.ev))")
                        .monospacedBody()
                }
            }
            .layoutPriority(1)

            VStack(alignment: .leading, spacing: 2) {
                ForEach(viewModels) { stat in
                    ProgressBar(progress: stat.fraction, color: stat.color, useRoundedProgress: true)
                }
            }
        }
    }

}

extension TeamMemberStats.ViewModel: Identifiable {

    var id: String { name }

}

// MARK: - HorizontalAlignment
private extension HorizontalAlignment {

    private enum StatAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[.leading]
        }
    }

    static let statAlignment = HorizontalAlignment(StatAlignment.self)

    private enum ValueAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[.trailing]
        }
    }

    static let valueAlignment = HorizontalAlignment(ValueAlignment.self)

}

private struct TeamMemberFactoids: View {

    @ObservedObject var member: TeamMemberViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            HStack {
                Factoid(title: "Ability", value: member.ability.name)
                Spacer(minLength: 0)
                Factoid(title: "Nature", value: member.nature.name)
                Spacer(minLength: 0)
                Factoid(title: "Shiny", value: member.isShiny ? "Yes" : "No")
            }
            HStack {
                Spacer(minLength: 0)
                Factoid(title: "Held Item", value: member.heldItem?.name ?? "N/A")
                Spacer(minLength: 0)
                Factoid(title: "Happiness", value: "\(member.happiness)")
                Spacer(minLength: 0)
            }
        }
    }

}

private extension Gender {

    var abbreviation: String? {
        switch self {
        case .male:
            return "M"
        case .female:
            return "F"
        case .unspecified:
            return nil
        }
    }

}
