//
//  MoveList.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/15/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI

struct MoveList: View {

    let game: Game

    @FetchRequest var moves: FetchedResults<Move>

    var body: some View {
        SearchableList(viewModel: SearchableListViewModel(objects: moves), searchPlaceholder: "Search for a move") { move in
            NavigationLink(destination: MoveDetail(move: move, game: self.game).injectDependencies()) {
                MoveCell(move: move, game: self.game)
            }
        }
        .navigationBarTitle("Moves")
    }

    init(game: Game) {
        self.game = game
        self._moves = FetchRequest(fetchRequest: Move.allFetchRequest(for: game), animation: .default)
    }

    init(type: PokemonType, game: Game) {
        self.game = game
        self._moves = FetchRequest(fetchRequest: Move.fetchRequest(forType: type, game: game))
    }

}

struct MoveList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MoveList(game: .crystal)
        }
        .injectDependencies()
    }
}
