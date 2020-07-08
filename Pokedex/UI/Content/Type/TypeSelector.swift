//
//  TypeSelector.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/9/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct TypeSelector: View {

    let title: String

    @Binding var selectedType: PokemonType
    @Environment(\.presentationMode) var presentationMode

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
    static var previews: some View {
        NavigationView {
            TypeSelector(title: "Select Type", selectedType: .constant(.fire))
        }
    }
}

struct TypeSelectorCell: View {

    let type: PokemonType

    @Binding var selectedType: PokemonType

    var body: some View {
        HStack {
            Text(type.rawValue)
                .monospacedBody()
            Spacer()
            if type == self.selectedType {
                Image(systemName: "checkmark")
            }
        }
    }

}
