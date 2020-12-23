//
//  PokemonTypeEffectiveness.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/4/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI

struct PokemonTypeEffectiveness: View {

    private let typeViewModels: [PokemonTypeEffectivenessViewModel]

    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    private var numberOfColumns: Int { horizontalSizeClass == .regular ? 6 : 3 }

    enum Kind: String, CaseIterable, Identifiable {

        case offense = "Offense"
        case defense = "Defense"

        var id: String { rawValue }

    }

    var body: some View {
        LazyVGrid(columns: Array(repeating: .init(), count: numberOfColumns), spacing: 8.0) {
            ForEach(typeViewModels) { viewModel in
                PokemonTypeEffectivenessCell(type: viewModel.type, value: viewModel.value)
            }
        }
    }

    init(primaryType: PokemonType, secondaryType: PokemonType?, kind: Kind, game: Game) {
        typeViewModels = TypeEffectiveness(primary: primaryType, secondary: secondaryType)
            .orderedTypeValues(for: kind, generation: game.generation)
    }

}

struct PokemonTypeEffectiveness_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section {
                PokemonTypeEffectiveness(primaryType: .fire, secondaryType: .flying, kind: .defense, game: .sword)
            }
            Section {
                PokemonTypeEffectiveness(primaryType: .electric, secondaryType: nil, kind: .offense, game: .sword)
            }
        }
        .listStyle(GroupedListStyle())
        .injectDependencies()
    }
}

private extension TypeEffectiveness {

    func orderedTypeValues(for kind: PokemonTypeEffectiveness.Kind, generation: Generation) -> [PokemonTypeEffectivenessViewModel] {
        PokemonType.allCases
            .sorted { PokemonType.allTypesByOrder.firstIndex(of: $0)! < PokemonType.allTypesByOrder.firstIndex(of: $1)! }
            .map { PokemonTypeEffectivenessViewModel(type: $0, value: kind == .offense ? self[offense: $0, generation] : self[defense: $0, generation]) }
    }

}

private struct PokemonTypeEffectivenessViewModel: Identifiable {

    let type: PokemonType
    let value: Double

    var id: String { type.rawValue }

}
