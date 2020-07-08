//
//  ItemCell.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/26/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct ItemCell: View {

    let item: Item

    var body: some View {
        HStack {
            ItemSprite(item: item)
            Text(item.name)
                .monospacedBody()
                .multilineTextAlignment(.leading)
        }
        .contentShape(Rectangle())
    }

}

struct ItemCell_Previews: PreviewProvider {
    static var previews: some View {
        ItemCell(item: Item.generateAntidote())
    }
}
