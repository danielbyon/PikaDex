//
//  MoveCell.swift
//  
//
//  Created by Daniel Byon on 9/29/22.
//

import PokedexCore
import SwiftUI

public struct MoveCell: View {

    let move: Move

    public var body: some View {
        HStack {
            Text(move.name)
                .monospacedBody()
            Spacer()
            VStack(spacing: 2.0) {
                Badge(pokemonType: move.type, equalWidths: true, isSmall: true)
                Badge(moveCategory: move.category, equalWidths: true, isSmall: true)
            }
        }
    }

    public init(move: Move) {
        self.move = move
    }

}

struct MoveCell_Previews: PreviewProvider {
    static var previews: some View {
        MoveCell(move: .psybeam)
    }
}
