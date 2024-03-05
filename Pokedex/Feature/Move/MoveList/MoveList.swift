//
//  MoveList.swift
//  
//
//  Created by Daniel Byon on 9/29/22.
//

import PokedexUI
import SwiftUI

public struct MoveList: View {

    @Query private var moves: QueryResults<Move>
    @State private var isShowingFilter = false

    private let game: Game
    private let type: PokemonType?

    public var body: some View {
        SearchableList(
            items: moves,
            query: $moves.query.toString(),
            searchPrompt: "Search for a move",
            id: \.index
        ) { move in
            NavigationLink(value: Route.content(.move(move))) {
                MoveCell(move: move)
            }
        }
        .navigationTitle("Moves")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                HomeButton()
            }
        }
        .onAppear {
            $moves.wrappedValue = .init(game: game, type: type)
        }
    }

    public init(
        game: Game,
        type: PokemonType? = nil
    ) {
        self.game = game
        self.type = type
    }

}

struct MoveList_Previews: PreviewProvider {
    static var previews: some View {
        PreviewContainer {
            MoveList(game: .sword)
        }
    }
}
