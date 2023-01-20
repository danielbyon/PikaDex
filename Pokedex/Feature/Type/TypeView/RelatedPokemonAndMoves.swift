//
//  RelatedPokemonAndMoves.swift
//  
//
//  Created by Daniel Byon on 10/10/22.
//

import DesignSystem
import PokedexUI
import SwiftUI

struct RelatedPokemonAndMoves: View {

    @Query private var moves: QueryResults<Move>
    @Query private var pokemonForms: QueryResults<PokemonDetailForm>
    @State private var selectedSegment: Segment = .pokemon

    let type: PokemonType
    let game: Game

    private enum Segment: String, CaseIterable, Identifiable {

        case pokemon = "Pokémon"
        case moves = "Moves"

        var id: String { rawValue }

    }

    var body: some View {
        Section {
            SegmentedControl(selectedSegment: $selectedSegment)

            switch selectedSegment {
            case .pokemon where pokemonForms.isEmpty:
                Text("There are no Pokémon with this type.")
            case .pokemon:
                ForEach(pokemonForms, id: \.self) { pokemonForm in
                    NavigationLink(value: Route.content(.pokemonDetailForm(pokemonForm, pokedex: .national))) {
                        PokemonCell(pokemonForm: pokemonForm)
                    }
                }
            case .moves where moves.isEmpty:
                Text("There are no Moves with this type.")
            case .moves:
                ForEach(moves, id: \.self) { move in
                    NavigationLink(value: Route.content(.move(move))) {
                        MoveCell(move: move)
                    }
                }
            }
        }
        .onAppear {
            updateQuery(forSelectedSegment: selectedSegment)
        }
        .onChange(of: selectedSegment, perform: updateQuery)
    }

    private func updateQuery(forSelectedSegment selectedSegment: Segment) {
        switch selectedSegment {
        case .pokemon:
            $pokemonForms.wrappedValue = .init(type: type, game: game)
        case .moves:
            $moves.wrappedValue = .init(game: game, type: type)
        }
    }

}

struct RelatedPokemonAndMoves_Previews: PreviewProvider {
    static var previews: some View {
        RelatedPokemonAndMoves(type: .electric, game: .sword)
    }
}
