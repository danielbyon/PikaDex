//
//  ItemCell.swift
//  
//
//  Created by Daniel Byon on 10/20/22.
//

import PokedexUI
import SwiftUI

public struct ItemCell: View {

    let item: Item

    public var body: some View {
        HStack {
            Sprite(item.spriteName, width: 24.0)
            Text(item.name)
                .monospacedBody()
                .multilineTextAlignment(.leading)
        }
        .contentShape(Rectangle())
    }

    public init(item: Item) {
        self.item = item
    }

}

struct ItemCell_Previews: PreviewProvider {
    static var previews: some View {
        ItemCell(item: .potion)
    }
}
