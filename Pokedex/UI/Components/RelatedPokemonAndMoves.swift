//
//  RelatedPokemonAndMoves.swift
//  Pokedex
//
//  Created by Daniel Byon on 2/26/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI
import CoreData

struct RelatedPokemonAndMoves: View {

    let game: Game

    @FetchRequest private var pokemonForms: FetchedResults<PokemonForm>
    @FetchRequest private var moves: FetchedResults<Move>
    @State private var selectedSegment: Segment = .pokemon

    var body: some View {
        Section {
            SegmentedControl(selectedSegment: $selectedSegment)

            switch selectedSegment {
            case .pokemon where pokemonForms.isEmpty:
                Text("There are no Pokémon with this type.")
            case .pokemon:
                AlternatingBackgroundForEach(pokemonForms) { pokemonForm in
                    NavigationLink(destination: PokemonDetail(pokemon: pokemonForm.pokemon, game: self.game, formIndex: pokemonForm.formIndex)) {
                        PokemonFormCell(form: pokemonForm, game: self.game)
                    }
                }
            case .moves where moves.isEmpty:
                Text("There are no Moves with this type.")
            case .moves:
                AlternatingBackgroundForEach(moves) { move in
                    NavigationLink(destination: MoveDetail(move: move, game: self.game)) {
                        MoveCell(move: move, game: self.game)
                    }
                }
            }
        }
    }

    private enum Segment: String, CaseIterable, Identifiable {

        case pokemon = "Pokémon"
        case moves = "Moves"

        var id: String { rawValue }

    }

    init(game: Game, pokemonRequest: NSFetchRequest<PokemonForm>, moveRequest: NSFetchRequest<Move>) {
        self.game = game
        self._pokemonForms = FetchRequest(fetchRequest: pokemonRequest)
        self._moves = FetchRequest(fetchRequest: moveRequest)
    }

    init(type: PokemonType, game: Game) {
        self.init(
            game: game,
            pokemonRequest: PokemonForm.fetchRequest(forType: type, game: game),
            moveRequest: Move.fetchRequest(forType: type, game: game))
    }

}

struct RelatedPokemonAndMoves_Previews: PreviewProvider {
    static var previews: some View {
        List {
            RelatedPokemonAndMoves(type: .fire, game: .sword)
                .injectDependencies()
        }
    }
}
