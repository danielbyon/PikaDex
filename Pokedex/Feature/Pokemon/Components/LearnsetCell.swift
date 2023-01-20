//
//  LearnsetCell.swift
//  
//
//  Created by Daniel Byon on 10/26/22.
//

import PokedexUI
import SwiftUI

public struct LearnsetCell: View {

    let move: Move
    let detailText: String?
    let game: Game

    public var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(move.name)
                    .monospacedBody()
                if let detailText = detailText {
                    Text(detailText)
                        .monospacedCaption()
                }
            }
            .multilineTextAlignment(.leading)
            Spacer()
            VStack(spacing: 2.0) {
                Badge(pokemonType: move.type, equalWidths: true, isSmall: true)
                Badge(moveCategory: move.category, equalWidths: true, isSmall: true)
            }
        }
        .contentShape(Rectangle())
    }

    public init(
        move: Move,
        detailText: String?,
        game: Game
    ) {
        self.move = move
        self.detailText = detailText
        self.game = game
    }

}
