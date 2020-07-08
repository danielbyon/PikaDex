//
//  MoveDetail.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/15/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI

struct MoveDetail: View {

    let move: Move
    let game: Game

    @State private var selectedLearnsetType: LearnsetType = .level

    private let dash = "－"
    private let targetSpacing: CGFloat = 2.0
    private let verticalPadding: CGFloat = 4.0

    var body: some View {
        List {
            Section {
                DescriptionCell(text: move.info.moveDescription)
            }

            Section(header: SectionHeader("Info")) {
                NavigationLink(destination: TypeDetail(type: move.type, game: game).injectDependencies()) {
                    HStack {
                        Text("Type")
                            .monospacedBody()
                        Spacer()
                        Badge(pokemonType: move.type)
                    }
                }
                HStack {
                    Text("Category")
                        .monospacedBody()
                    Spacer()
                    Badge(moveCategory: move.info.category)
                }
                Value1Cell(text: "Power", detailText: move.info.power != nil ? "\(move.info.power!)" : dash)
                Value1Cell(text: "Accuracy", detailText: move.info.accuracy != nil ? "\(move.info.accuracy!)" : dash)
                Value1Cell(text: "PP", detailText: move.info.pp != nil ? "\(move.info.pp!)" : dash)
                if move.info.maxPP != nil {
                    Value1Cell(text: "Max PP", detailText: "\(move.info.maxPP!)")
                }
            }

            Section(header: SectionHeader("Type Effectiveness")) {
                PokemonTypeEffectiveness(primaryType: move.type, secondaryType: nil, kind: .offense, game: game)
                    .padding(.vertical, verticalPadding)
            }

            Section(header: SectionHeader("Target")) {
                HStack(spacing: targetSpacing) {
                    VStack(spacing: targetSpacing) {
                        TargetComponent(title: "Enemy", enabled: move.info.targetEnemy1)
                        TargetComponent(title: "Self", enabled: move.info.targetSelf)
                    }
                    VStack(spacing: targetSpacing) {
                        TargetComponent(title: "Enemy", enabled: move.info.targetEnemy2)
                        TargetComponent(title: "Ally", enabled: move.info.targetAlly1)
                    }
                    VStack(spacing: targetSpacing) {
                        TargetComponent(title: "Enemy", enabled: move.info.targetEnemy3)
                        TargetComponent(title: "Ally", enabled: move.info.targetAlly2)
                    }
                }
                .padding(.top, verticalPadding)
                Text(move.info.targetDescription)
                    .monospacedBody()
                    .padding(.bottom, verticalPadding)
                    .centered()
            }

            Section(header: SectionHeader("Availability")) {
                Value1Cell(text: "Introduced", detailText: move.generationIntroduced.title)
            }

            Section {
                SegmentedControl(titles: LearnsetType.allTitles(for: game), values: LearnsetType.allCases(for: game), selectedSegmentIndex: $selectedLearnsetType)
                if selectedLearnsetType == .level {
                    MoveLearnsetGroup(title: "Level", game: game, learnsetFetchRequest: LevelLearnsetEntry.fetchRequest(for: move, game: game))
                } else if selectedLearnsetType == .machine {
                    MoveLearnsetGroup(title: "Machine", game: game, learnsetFetchRequest: MachineLearnsetEntry.fetchRequest(for: move, game: game))
                } else if selectedLearnsetType == .breed {
                    MoveLearnsetGroup(title: "Breeding", game: game, learnsetFetchRequest: BreedLearnsetEntry.fetchRequest(for: move, game: game))
                } else if selectedLearnsetType == .tutor {
                    MoveLearnsetGroup(title: "Tutoring", game: game, learnsetFetchRequest: TutorLearnsetEntry.fetchRequest(for: move, game: game))
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle(Text(move.name), displayMode: .large)
    }

}

struct MoveDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MoveDetail(move: Move.generateThunderShock(), game: .sword)
        }
        .injectDependencies()
    }
}

struct TargetComponent: View {

    var title: String
    var enabled: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4.0)
                .fill(Color(enabled ? PokemonColor.red.uiColor : PokemonColor.gray.uiColor))
                .opacity(0.7)
            Text(title)
                .monospacedBody()
                .padding(.vertical, 4.0)
        }
    }

}
