//
//  GameDetail.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/22/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct GameDetail: View {

    let game: Game
    let selectAction: () -> Void

    var body: some View {
        List {
            Text(game.title)


        }
        .listStyle(GroupedListStyle())
        .navigationTitle(game.title)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Select", action: selectAction)
            }
        }
    }

}

struct GameDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GameDetail(game: .sword, selectAction: {})
        }
    }
}
