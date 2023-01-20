//
//  TypeView.swift
//  
//
//  Created by Daniel Byon on 10/10/22.
//

import DesignSystem
import PokedexUI
import SwiftUI

public struct TypeView: View {

    @State private var selectedTypeEffectiveness: TypeEffectiveness.Kind = .offense

    public let type: PokemonType
    public let game: Game

    public var body: some View {
        List {
            Section {
                SegmentedControl(selectedSegment: $selectedTypeEffectiveness)
                PokemonTypeEffectiveness(
                    primaryType: type,
                    secondaryType: nil,
                    kind: selectedTypeEffectiveness,
                    game: game
                )
                    .padding(.vertical)
            } header: {
                SectionHeader("Type Effectiveness")
            }

            RelatedPokemonAndMoves(type: type, game: game)
        }
        .listStyle(.grouped)
        .navigationTitle(type.rawValue)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                HomeButton()
            }
        }
    }

}

struct TypeView_Previews: PreviewProvider {
    static var previews: some View {
        TypeView(
            type: .electric,
            game: .sword
        )
    }
}
