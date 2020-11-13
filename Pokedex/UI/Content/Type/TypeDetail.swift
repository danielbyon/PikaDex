//
//  TypeDetail.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/8/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI

struct TypeDetail: View {
    
    let type: PokemonType
    let game: Game

    @State private var selectedTypeEffectiveness: PokemonTypeEffectiveness.Kind = .offense

    var body: some View {
        List {
            Section(header: SectionHeader("Type Effectiveness")) {
                SegmentedControl(selectedSegment: $selectedTypeEffectiveness)
                PokemonTypeEffectiveness(primaryType: type, secondaryType: nil, kind: selectedTypeEffectiveness, game: game)
                    .padding(.vertical)
            }

            RelatedPokemonAndMoves(type: type, game: game)
        }
        .listStyle(GroupedListStyle())
        .navigationTitle(type.rawValue)
    }

}

struct TypeDetail_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                TypeDetail(type: .flying, game: .sword)
                    .injectDependencies()
            }
        }
    }
}
