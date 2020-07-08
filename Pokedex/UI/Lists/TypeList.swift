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
            GridView(elements: PokemonType.allTypes(for: game).sorted(), numberOfItemsPerRow: 2) { type in
                NavigationLink(destination: TypeDetail(type: type, game: self.game).injectDependencies()) {
                    BigColoredButton(title: type.rawValue, fillColor: type.color)
                }
            }
            .padding()
        }
        .navigationBarTitle("Types")
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
