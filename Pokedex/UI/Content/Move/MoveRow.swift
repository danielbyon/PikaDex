//
//  MoveCell.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/15/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI

struct MoveCell: View {

    let move: Move
    let game: Game

    var body: some View {
        HStack {
            Text(move.name)
                .font(.body)
            Spacer()
            VStack(spacing: 2.0) {
                Badge(pokemonType: move.type, equalWidths: true)
                if move.info(forGame: game) != nil {
                    Badge(moveCategory: move.info(forGame: game)!.category, equalWidths: true)
                }
            }
        }
    }
}

struct MoveRow_Previews: PreviewProvider {
    static var previews: some View {
        MoveCell(move: Move.generateThunderShock(), game: .sword)
    }
}
