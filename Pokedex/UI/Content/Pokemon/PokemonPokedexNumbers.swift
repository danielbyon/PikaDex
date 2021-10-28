//
//  PokemonPokedexNumbers.swift
//  Pokedex
//
//  Created by Daniel Byon on 1/26/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct PokemonPokedexNumbers: View {

    let pokedexNumbers: PokedexNumbers

    private var viewModels: [PokedexNumberViewModel] {
        let allNumbers = pokedexNumbers.all()
        return allNumbers.compactMap { PokedexNumberViewModel(name: $0.0, number: $0.1) }
    }

    var body: some View {
        ForEach(viewModels) { viewModel in
            Value1Cell(text: viewModel.name, detailText: viewModel.number)
        }
    }

}

struct PokemonPokedexNumbers_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PokemonPokedexNumbers(pokedexNumbers: StoredPokemon.generateCharizard().pokedexNumbers)
                .centered()
        }
    }
}

private struct PokedexNumberViewModel {
    let name: String
    let number: String

    init?(name: String, number: Int) {
        guard let numberString = NumberFormatter.threeDigit.string(from: NSNumber(value: number)) else { return nil }
        self.name = name
        self.number = numberString
    }
}

extension PokedexNumberViewModel: Identifiable {

    var id: String { name }

}

// MARK: - HorizontalAlignment
private extension HorizontalAlignment {

    private enum NumberAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[HorizontalAlignment.center]
        }
    }

    static let numberAlignment = HorizontalAlignment(NumberAlignment.self)

}
