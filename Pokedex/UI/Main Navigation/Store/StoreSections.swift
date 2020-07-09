//
//  StoreSections.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/28/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI
import StoreKit

struct StoreSections: View {

    let consoleProducts: [ProductViewModel]
    let gameProducts: [ProductViewModel]
    let tipProducts: [ProductViewModel]
    let isPurchasing: Bool
    let onTap: (ProductViewModel) -> Void

    private var tipFooter: String {
        """
        Tips are greatly appreciated!

        All proceeds go to supporting updates and new features!
        """
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 44.0) {
            StoreSection(header: nil, footer: nil, products: consoleProducts, isPurchasing: isPurchasing) {
                self.onTap($0)
            }

//            StoreSection(header: "Per Game Family", footer: nil, products: gameProducts, isPurchasing: isPurchasing) {
//                self.onTap($0)
//            }

            StoreSection(header: "Tips", footer: tipFooter, products: tipProducts, isPurchasing: isPurchasing) {
                self.onTap($0)
            }
        }
    }

}

struct StoreSections_Previews: PreviewProvider {
    static var previews: some View {
        StoreSections(
            consoleProducts: [
                ProductViewModel(description: "Test product Test product Test product Test product Test product Test product Test product Test product ", pokepediaProduct: .allGames, price: "$4.99", product: SKProduct(), title: "All Games"),
                ProductViewModel(description: "Test product", pokepediaProduct: .all3DSGames, price: "$1.99", product: SKProduct(), title: "All 3DS Games")
            ],
            gameProducts: [
                ProductViewModel(description: nil, pokepediaProduct: .rubySapphireEmerald, price: "$0.99", product: SKProduct(), title: "Ruby/Sapphire/Emerald")
            ],
            tipProducts: [
                ProductViewModel(description: nil, pokepediaProduct: .smallTip, price: "$0.99", product: SKProduct(), title: "Small Tip")
            ],
            isPurchasing: false,
            onTap: { _ in })
    }
}
