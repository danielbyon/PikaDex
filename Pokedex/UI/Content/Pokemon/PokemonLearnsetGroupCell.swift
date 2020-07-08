//
//  PokemonLearnsetGroupCell.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/2/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct PokemonLearnsetGroupCell: View {

    let move: Move
    let detailText: String?
    let game: Game

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(move.name)
                    .monospacedBody()
                if detailText != nil {
                    Text(detailText!)
                        .monospacedCaption()
                }
            }
            .multilineTextAlignment(.leading)
            Spacer()
            MoveBadges(move: move, game: game)
        }
        .contentShape(Rectangle())
    }

}

struct PokemonLearnsetGroupCell_Previews: PreviewProvider {
    static var previews: some View {
        PokemonLearnsetGroupCell(move: Move.generateThunderShock(), detailText: "Lv.12", game: .sword)
    }
}
