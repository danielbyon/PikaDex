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
                .monospacedBody()
            Spacer()
            MoveBadges(move: move, game: game)
        }
        .contentShape(Rectangle())
    }
}

struct MoveRow_Previews: PreviewProvider {
    static var previews: some View {
        MoveCell(move: Move.generateThunderShock(), game: .sword)
    }
}
