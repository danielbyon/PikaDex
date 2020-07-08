//
//  StoreSection.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/28/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI
import StoreKit

struct StoreSection: View {

    let header: String
    let footer: String?
    let products: [ProductViewModel]
    let isPurchasing: Bool
    let onTap: (ProductViewModel) -> Void

    private var cells: some View {
        VStack(alignment: .leading, spacing: 16.0) {
            ForEach(products) { product in
                Button(action: {
                    self.onTap(product)
                }) {
                    StoreCell(product: product)
                }
                .disabled(self.isPurchasing)
            }
        }
    }

    var body: some View {
        if !products.isEmpty {
            return AnyView(
                VStack(alignment: .leading, spacing: 8.0) {
                    HStack {
                        Text(header)
                            .font(.title)
                            .bold()
                        Spacer()
                    }
                    cells
                    if footer != nil {
                        Text(footer!)
                            .font(.caption)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            )
        } else {
            return AnyView(EmptyView())
        }
    }

}

struct StoreSection_Previews: PreviewProvider {
    static var previews: some View {
        StoreSection(
            header: "Console Packages",
            footer: "Some footer text",
            products: [
                ProductViewModel(description: "Test product Test product Test product Test product Test product Test product Test product Test product ", pokepediaProduct: .allGames, price: "$4.99", product: SKProduct(), title: "All Games"),
                ProductViewModel(description: "Test product", pokepediaProduct: .all3DSGames, price: "$1.99", product: SKProduct(), title: "All 3DS Games")
            ],
            isPurchasing: false,
            onTap: { _ in })
    }
}
