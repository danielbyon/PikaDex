//
//  TeamMemberCell.swift
//  
//
//  Created by Daniel Byon on 10/30/22.
//

import PokedexUI
import SwiftUI

struct TeamMemberCell: View {

    @ObservedObject var viewModel: TeamMemberViewModel

    @Environment(\.pokedexDataStore) private var dataStore

    private var pokemonForm: PokemonDetailForm? {
        try? dataStore.fetch(PokemonDetailForm.self, filter: PokemonDetailFormFilter(
            pokemonName: viewModel.teamMember.pokemon,
            formName: viewModel.teamMember.formName,
            game: viewModel.teamMember.game
        ))
        .first
    }

    @ViewBuilder
    var body: some View {
        let _ = Self._printChanges()
        if let pokemonForm {
            Card {
                VStack(alignment: .leading, spacing: 16.0) {
                    TeamMemberFormInfo(form: pokemonForm, nickname: viewModel.teamMember.nickname, gender: viewModel.teamMember.gender)
                    TeamMemberMoves(viewModel: viewModel)
                    TeamMemberStats(viewModel: viewModel)
                    TeamMemberFactoids(viewModel: viewModel)
                }
            }
        }
    }

    init(
        viewModel: TeamMemberViewModel
    ) {
        self.viewModel = viewModel
    }

}

struct TeamMemberCell_Previews: PreviewProvider {
    static var previews: some View {
        TeamMemberCell(
            viewModel: .init(
                teamMember: Team.stub1.members[0],
                team: .stub1
            )
        )
    }
}

private struct TeamMemberFormInfo: View {

    let form: PokemonDetailForm
    let nickname: String
    let gender: Gender

    private var resolvedName: String {
        var retVal = form.pokemonName
        if !nickname.isEmpty {
            retVal = nickname
        }
        if let abbreviation = gender.abbreviation {
            retVal += " (\(abbreviation))"
        }
        return retVal
    }
    private var shouldShowFormName: Bool { !nickname.isEmpty || form.name != form.pokemonName }

    var body: some View {
        HStack {
            Sprite(form.spriteName)
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
                if let secondaryType = form.secondaryType {
                    Badge(pokemonType: secondaryType, equalWidths: true, isSmall: true)
                }
            }
        }
    }
}

private struct TeamMemberMoves: View {

    @ObservedObject var viewModel: TeamMemberViewModel

    @Environment(\.pokedexDataStore) private var dataStore

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
            if let move1 = viewModel.move1 {
                MoveCell(move: move1)
            } else {
                noMove
            }
            if let move2 = viewModel.move2 {
                MoveCell(move: move2)
            } else {
                noMove
            }
            if let move3 = viewModel.move3 {
                MoveCell(move: move3)
            } else {
                noMove
            }
            if let move4 = viewModel.move4 {
                MoveCell(move: move4)
            } else {
                noMove
            }
        }
    }

}

private struct TeamMemberStats: View {

    @ObservedObject var viewModel: TeamMemberViewModel

    private var member: TeamMember { viewModel.teamMember }

    private var statViewModels: [StatViewModel] {
        [
            .init(
                name: "HP",
                value: member.calculatedHP,
                iv: member.hp.iv,
                ev: member.hp.ev,
                color: Color(Stats.hpColor)
            ),
            .init(
                name: "ATK",
                value: member.calculatedAttack,
                iv: member.attack.iv,
                ev: member.attack.ev,
                color: Color(Stats.attackColor)
            ),
            .init(
                name: "DEF",
                value: member.calculatedDefense,
                iv: member.defense.iv,
                ev: member.defense.ev,
                color: Color(Stats.defenseColor)
            ),
            .init(
                name: "SPA",
                value: member.calculatedSpecialAttack,
                iv: member.specialAttack.iv,
                ev: member.specialAttack.ev,
                color: Color(Stats.specialAttackColor)
            ),
            .init(
                name: "SDF",
                value: member.calculatedSpecialDefense,
                iv: member.specialDefense.iv,
                ev: member.specialDefense.ev,
                color: Color(Stats.specialDefenseColor)
            ),
            .init(
                name: "SPD",
                value: member.calculatedSpeed,
                iv: member.speed.iv,
                ev: member.speed.ev,
                color: Color(Stats.speedColor)
            ),
        ]
    }

    struct StatViewModel {

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
                ForEach(statViewModels) { stat in
                    Text(stat.name + ":")
                        .alignmentGuide(.statAlignment, computeValue: { d in d[.trailing] })
                        .monospacedBody()
                }
            }
            .layoutPriority(1)

            VStack(alignment: .trailing, spacing: 2) {
                ForEach(statViewModels) { stat in
                    Text("\(stat.value)")
                        .monospacedBody()
                }
            }
            .layoutPriority(1)

            VStack(alignment: .leading, spacing: 2) {
                ForEach(statViewModels) { stat in
                    Text("(\(stat.iv)/\(stat.ev))")
                        .monospacedBody()
                }
            }
            .layoutPriority(1)

            VStack(alignment: .leading, spacing: 2) {
                ForEach(statViewModels) { stat in
                    ProgressBar(
                        progress: stat.fraction,
                        color: stat.color,
                        useRoundedProgress: true
                    )
                }
            }
        }
    }

}

extension TeamMemberStats.StatViewModel: Identifiable {

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

private struct TeamMemberFactoids: View {

    @ObservedObject var viewModel: TeamMemberViewModel

    private var member: TeamMember { viewModel.teamMember }

    var body: some View {
        VStack(alignment: .leading, spacing: 8.0) {
            HStack {
                if let ability = member.ability {
                    Factoid(title: "Ability", value: ability)
                    Spacer(minLength: 0)
                }
                if let nature = member.nature {
                    Factoid(title: "Nature", value: nature)
                    Spacer(minLength: 0)
                }
                Factoid(title: "Shiny", value: member.isShiny ? "Yes" : "No")
            }
            HStack {
                Spacer(minLength: 0)
                if let heldItem = member.heldItem {
                    Factoid(title: "Held Item", value: heldItem)
                    Spacer(minLength: 0)
                }
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
