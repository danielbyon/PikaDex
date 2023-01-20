//
//  ItemPriceCell.swift
//  
//
//  Created by Daniel Byon on 10/21/22.
//

import PokedexUI
import SwiftUI

struct ItemPriceCell: View {

    let title: String
    let price: Int
    let generation: Generation

    @Environment(\.sizeCategory) var sizeCategory

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            HStack(spacing: 4) {
                generation.priceSprite
                    .interpolation(.low)
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(height: UIFont.preferredFont(forTextStyle: .body).pointSize)
                Text("\(price)")
                    .fixedSize(horizontal: true, vertical: true)
            }
        }
        .monospacedBody()
        .contentShape(Rectangle())
        .foregroundColor(.primary)
    }

}

struct ItemPriceCell_Previews: PreviewProvider {
    static var previews: some View {
        ItemPriceCell(title: "Cost", price: 300, generation: 1)
    }
}

private extension Generation {

    var priceSprite: Image {
        Image("Price/generation\(rawValue)")
    }

}
