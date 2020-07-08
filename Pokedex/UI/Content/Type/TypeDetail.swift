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
                SegmentedControl(titles: PokemonTypeEffectiveness.Kind.allCases.map { $0.rawValue }, values: PokemonTypeEffectiveness.Kind.allCases, selectedSegmentIndex: $selectedTypeEffectiveness)
                PokemonTypeEffectiveness(primaryType: type, secondaryType: nil, kind: selectedTypeEffectiveness, game: game)
                    .padding(.vertical)
            }

            RelatedPokemonAndMoves(type: type, game: game)
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle(Text(type.rawValue), displayMode: .large)
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
