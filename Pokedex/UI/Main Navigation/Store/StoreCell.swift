//
//  StoreCell.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/28/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI
import StoreKit

struct StoreCell: View {

    let product: ProductViewModel

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 8.0) {
                HStack(alignment: .firstTextBaseline) {
                    Text(product.title)
                        .monospacedHeadline()
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    if product.price != nil {
                        Badge(title: product.price!, fillColor: AppColor.red.uiColor)
                    }
                }
                if product.description != nil {
                    Text(product.description!)
                        .monospacedCaption()
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .contentShape(Rectangle())
    }

}

struct StoreCell_Previews: PreviewProvider {
    static var previews: some View {
        StoreCell(product: ProductViewModel(description: "Test product Test product Test product Test product Test product Test product Test product Test product ", pokepediaProduct: .allGames, price: "$4.99", product: SKProduct(), title: "All Games"))
    }
}
