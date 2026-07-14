//
//  ItemBagInfoView.swift
//  
//
//  Created by Daniel Byon on 10/21/22.
//

import PokedexUI
import SwiftUI

struct ItemBagInfoView: View {

    let info: Item.BagInfo
    let game: Game
    let generationIntroduced: Generation

    private let noPrice = "\u{2014}"

    var body: some View {
        Section {
            if let pocket = info.pocket {
                Value1Cell(text: "Pocket", detailText: pocket.title(forGame: game))
            }
            Value1Cell(text: "Introduced", detailText: generationIntroduced.title)
        }

        if info.cost != nil || info.sell != nil {
            Section {
                if let cost = info.cost {
                    ItemPriceCell(title: "Cost", price: cost, generation: game.metadata?.generation)
                }
                if let sell = info.sell {
                    ItemPriceCell(title: "Sell Price", price: sell, generation: game.metadata?.generation)
                }
            }
        }
    }

}

struct ItemBagInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ItemBagInfoView(
            info: .init(
                itemDescription: "Heals your shit, bitch",
                cost: 300,
                sell: 150,
                pocket: .medicine
            ),
            game: .sword,
            generationIntroduced: 1
        )
    }
}
