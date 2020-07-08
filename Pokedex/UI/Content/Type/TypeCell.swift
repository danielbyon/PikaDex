//
//  TypeCell.swift
//  Pokedex
//
//  Created by Daniel Byon on 2/29/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct TypeCell: View {

    let type: PokemonType
    let game: Game

    var body: some View {
        NavigationLink(destination: TypeDetail(type: self.type, game: self.game).injectDependencies()) {
            BigColoredButton(title: type.rawValue, fillColor: type.color)
        }
    }

}

struct TypeCell_Previews: PreviewProvider {
    static var previews: some View {
        TypeCell(type: .fire, game: .sword)
    }
}
