//
//  TypeList.swift
//  
//
//  Created by Daniel Byon on 10/21/22.
//

import PokedexUI
import SwiftUI

public struct TypeList: View {

    let game: Game

    public var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: .init(spacing: 16.0), count: 2), spacing: 16.0) {
                ForEach(PokemonType.allTypes(for: game).sorted()) { type in
                    NavigationLink(value: Route.content(.type(type, game: game))) {
                        BigColoredButton(title: type.rawValue, fillColor: Color(type.color))
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Types")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                HomeButton()
            }
        }
    }

    public init(game: Game) {
        self.game = game
    }

}

struct TypeList_Previews: PreviewProvider {
    static var previews: some View {
        TypeList(game: .sword)
    }
}
