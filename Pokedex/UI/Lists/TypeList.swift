//
//  TypeList.swift
//  Pokedex
//
//  Created by Daniel Byon on 2/25/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct TypeList: View {

    let game: Game

    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: .init(spacing: 16.0), count: 2), spacing: 16.0) {
                ForEach(PokemonType.allTypes(for: game).sorted()) { type in
                    NavigationLink(destination: TypeDetail(type: type, game: self.game)) {
                        BigColoredButton(title: type.rawValue, fillColor: Color(type.color))
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Types")
    }

}

struct TypeList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TypeList(game: .sword)
                .injectDependencies()
        }
    }
}
