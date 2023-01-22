//
//  TypeSelector.swift
//  
//
//  Created by Daniel Byon on 10/22/22.
//

import PokedexUI
import SwiftUI

struct TypeSelector: View {

    let title: String

    @Binding var selectedType: PokemonType

    private var types: [PokemonType] { PokemonType.allCases.sorted() }

    var body: some View {
        Picker(selection: $selectedType, label: Text(title).monospacedBody()) {
            ForEach(types) { type in
                Text(type.rawValue)
                    .monospacedBody()
                    .tag(type)
            }
        }
    }
}

struct TypeSelector_Previews: PreviewProvider {
    @State private static var selectedType: PokemonType = .fire

    static var previews: some View {
        TypeSelector(title: "Primary Type", selectedType: $selectedType)
    }
}
