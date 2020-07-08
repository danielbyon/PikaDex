//
//  ProductViewModel.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/28/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import StoreKit

struct ProductViewModel {

    let description: String?
    let pokepediaProduct: PokepediaProduct
    let price: String?
    let product: SKProduct
    let title: String

    init?(product: SKProduct, discountPercent: Int?, showDescription: Bool) {
        guard let pokepediaProduct = PokepediaProduct(rawValue: product.productIdentifier) else { return nil }
        let discountSuffix: String
        if let discountPercent = discountPercent {
            discountSuffix = ", with a \(discountPercent)% discount compared to purchasing individual games"
        } else {
            discountSuffix = ""
        }
        self.init(
            description: showDescription ? product.localizedDescription + discountSuffix : nil,
            pokepediaProduct: pokepediaProduct,
            price: product.localizedPrice,
            product: product,
            title: product.localizedTitle)
    }

    init(
        description: String?,
        pokepediaProduct: PokepediaProduct,
        price: String?,
        product: SKProduct,
        title: String) {
        self.description = description
        self.pokepediaProduct = pokepediaProduct
        self.price = price
        self.product = product
        self.title = title
    }

}

extension ProductViewModel: Equatable {

    static func == (lhs: ProductViewModel, rhs: ProductViewModel) -> Bool {
        lhs.product == rhs.product
    }

}

extension ProductViewModel: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(product)
    }

}

extension ProductViewModel: Identifiable {

    var id: String { title + String(describing: description) + String(describing: price) }

}

private let percentFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .percent
    return formatter
}()
