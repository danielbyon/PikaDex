//
//  MoveView.swift
//  
//
//  Created by Daniel Byon on 9/29/22.
//

import PokedexCore
import PokedexUI
import SwiftUI

public struct MoveView: View {

    @Query private var learnsetEntries: QueryResults<PokedexCore.LearnsetEntry>
    @State private var selectedLearnsetType: LearnsetType = .level

    let move: Move

    private var powerText: String {
        guard let power = move.power,
              power > 0 else {
            return dash
        }
        return "\(power)"
    }
    private var accuracyText: String {
        guard let accuracy = move.accuracy,
              accuracy > 0 else {
            return dash
        }
        return "\(accuracy)"
    }
    private var ppText: String {
        guard let pp = move.pp,
              pp > 0 else {
            return dash
        }
        return "\(pp)"
    }
    private var maxPPText: String? {
        guard let maxPP = move.maxPP,
              maxPP > 0 else { return nil }
        return "\(maxPP)"
    }
    private let dash = "－"
    private let targetSpacing: CGFloat = 2.0
    private let verticalPadding: CGFloat = 4.0

    public var body: some View {
        List {
            Section {
                DescriptionCell(text: move.moveDescription)
            }

            Section {
                NavigationLink(value: Route.content(.type(move.type, game: move.game))) {
                    Text("Type")
                        .monospacedBody()
                    Spacer()
                    Badge(pokemonType: move.type)
                }

                HStack {
                    Text("Category")
                        .monospacedBody()
                    Spacer()
                    Badge(moveCategory: move.category)
                }
                Value1Cell(text: "Power", detailText: powerText)
                Value1Cell(text: "Accuracy", detailText: accuracyText)
                Value1Cell(text: "PP", detailText: ppText)
                if let maxPPText {
                    Value1Cell(text: "Max PP", detailText: maxPPText)
                }
            } header: {
                SectionHeader("Info")
            }

            PokemonTypeEffectiveness(
                primaryType: move.type,
                secondaryType: nil,
                kind: .offense,
                game: move.game
            )

            Section {
                HStack(spacing: targetSpacing) {
                    VStack(spacing: targetSpacing) {
                        MoveTargetView(title: "Enemy", enabled: move.targetEnemy1)
                        MoveTargetView(title: "Self", enabled: move.targetSelf)
                    }
                    VStack(spacing: targetSpacing) {
                        MoveTargetView(title: "Enemy", enabled: move.targetEnemy2)
                        MoveTargetView(title: "Ally", enabled: move.targetAlly1)
                    }
                    VStack(spacing: targetSpacing) {
                        MoveTargetView(title: "Enemy", enabled: move.targetEnemy3)
                        MoveTargetView(title: "Ally", enabled: move.targetAlly2)
                    }
                }
                .padding(.top, verticalPadding)

                Text(move.targetDescription)
                    .monospacedBody()
                    .padding(.bottom, verticalPadding)
                    .centered()
            } header: {
                SectionHeader("Target")
            }

            Section {
                Value1Cell(text: "Introduced", detailText: move.generationIntroduced.title)
            } header: {
                SectionHeader("Availability")
            }

            Section {
                SegmentedControl(selectedSegment: $selectedLearnsetType, segments: LearnsetType.allCases(for: move.game))
                switch selectedLearnsetType {
                case .level:
                    MoveLearnsetGroup(title: "Level", game: move.game, entries: learnsetEntries)
                case .machine:
                    MoveLearnsetGroup(title: "Machine", game: move.game, entries: learnsetEntries)
                case .breeding:
                    MoveLearnsetGroup(title: "Breeding", game: move.game, entries: learnsetEntries)
                case .tutoring:
                    MoveLearnsetGroup(title: "Tutoring", game: move.game, entries: learnsetEntries)
                }
            }

            Section {
                NavigationLink(value: Route.url(move.bulbapediaURL)) {
                    Text("View on Bulbapedia")
                }
                NavigationLink(value: Route.url(move.pokemonDBURL)) {
                    Text("View on Pokemon DB")
                }
            } header: {
                SectionHeader("External Links")
            } footer: {
                ExternalLinksDisclaimer()
            }
        }
        .listStyle(.grouped)
        .navigationTitle(move.name)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                HomeButton()
            }
        }
        .onAppear {
            updateFilter(forLearnsetType: selectedLearnsetType)
        }
        .onChange(of: selectedLearnsetType, perform: updateFilter)
    }

    private func updateFilter(forLearnsetType learnsetType: LearnsetType) {
        switch learnsetType {
        case .level:
            $learnsetEntries.wrappedValue = .level(move: move)
        case .machine:
            $learnsetEntries.wrappedValue = .machine(move: move)
        case .breeding:
            $learnsetEntries.wrappedValue = .breeding(move: move)
        case .tutoring:
            $learnsetEntries.wrappedValue = .tutoring(move: move)
        }
    }

}

struct MoveView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewContainer {
            MoveView(move: .psybeam)
        }
    }
}
