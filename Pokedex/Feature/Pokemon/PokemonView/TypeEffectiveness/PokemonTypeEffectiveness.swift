//
//  PokemonTypeEffectiveness.swift
//  
//
//  Created by Daniel Byon on 9/28/22.
//

import PokedexUI
import SwiftUI

public struct PokemonTypeEffectiveness: View {

    private let typeViewModels: [PokemonTypeEffectivenessViewModel]

    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    private var numberOfColumns: Int { horizontalSizeClass == .regular ? 6 : 3 }

    public var body: some View {
        LazyVGrid(columns: Array(repeating: .init(), count: numberOfColumns), spacing: 8.0) {
            ForEach(typeViewModels) { viewModel in
                PokemonTypeEffectivenessCell(type: viewModel.type, value: viewModel.value)
            }
        }
    }

    public init(primaryType: PokemonType, secondaryType: PokemonType?, kind: TypeEffectiveness.Kind, game: Game) {
        typeViewModels = TypeEffectiveness(primary: primaryType, secondary: secondaryType)
            .orderedTypeValues(for: kind, generation: game.typeEffectivenessRulesGeneration)
    }

}

struct PokemonTypeEffectiveness_Previews: PreviewProvider {
    static var previews: some View {
        PreviewContainer {
            List {
                Section {
                    PokemonTypeEffectiveness(primaryType: .fire, secondaryType: .flying, kind: .defense, game: .sword)
                }
                Section {
                    PokemonTypeEffectiveness(primaryType: .electric, secondaryType: nil, kind: .offense, game: .sword)
                }
            }
            .listStyle(.grouped)
        }
    }
}

private extension TypeEffectiveness {

    func orderedTypeValues(for kind: TypeEffectiveness.Kind, generation: Generation) -> [PokemonTypeEffectivenessViewModel] {
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
