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
    @State private var selectedRelated = 0

    var body: some View {
        Section {
            SegmentedControl(titles: ["Pokémon", "Moves"], values: [0, 1], selectedSegmentIndex: $selectedRelated)
            if selectedRelated == 0 {
                if !pokemonForms.isEmpty {
                    AlternatingBackgroundForEach(pokemonForms) { pokemonForm in
                        NavigationLink(destination: PokemonDetail(pokemon: pokemonForm.pokemon, game: self.game, formIndex: pokemonForm.formIndex).injectDependencies()) {
                            PokemonFormCell(form: pokemonForm, game: self.game)
                        }
                    }
                } else {
                    Text("There are no Pokémon with this type.")
                }
            } else {
                if !moves.isEmpty {
                    AlternatingBackgroundForEach(moves) { move in
                        NavigationLink(destination: MoveDetail(move: move, game: self.game).injectDependencies()) {
                            MoveCell(move: move, game: self.game)
                        }
                    }
                } else {
                    Text("There are no Moves with this type.")
                }
            }
        }
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
