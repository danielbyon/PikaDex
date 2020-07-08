//
//  ItemDetail.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/26/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct ItemDetail: View {

    let item: Item
    let game: Game

    private var description: String? {
        switch item.itemType {
        case .item:
            return item.bagInfo?.itemDescription
        case .berry:
            return item.berryInfo?.itemDescription
        }
    }

    var body: some View {
        List {
            if description != nil {
                Section {
                    DescriptionCell(text: description!)
                }
            }

            if item.itemType == .berry {
                BerryItemInfoDetail(item: item, game: game)
            } else if item.itemType == .item {
                BagItemInfoDetail(item: item, game: game)
            }

//            Section(header: SectionHeader("Locations")) {
//                Text("Coming soon!")
//                    .monospacedBody()
//            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle(Text(item.name), displayMode: .large)
    }

}

struct ItemDetail_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                ItemDetail(item: Item.generateAntidote(), game: .sword)
            }
            .injectDependencies()
            NavigationView {
                ItemDetail(item: Item.generateRawstBerry(), game: .ruby)
            }
            .injectDependencies()
        }
    }
}

struct BagItemInfoDetail: View {

    let item: Item
    let game: Game
    var info: BagItemInfo { item.bagInfo! }

    private let noPrice = "\u{2014}"

    var body: some View {
        Group {
            Section {
                Value1Cell(text: "Pocket", detailText: info.pocket.title(forGame: game), image: nil)
                Value1Cell(text: "Introduced", detailText: item.generationIntroduced.title)
            }

            if info.cost != nil || info.sell != nil {
                Section {
                    if info.cost != nil {
                        ItemPriceCell(title: "Cost", price: info.cost!.intValue, generation: game.generation)
                    }
                    if info.sell != nil {
                        ItemPriceCell(title: "Sell Price", price: info.sell!.intValue, generation: game.generation)
                    }
                }
            }
        }
    }

}

struct BerryItemInfoDetail: View {

    let item: Item
    let game: Game
    var info: BerryItemInfo { item.berryInfo! }

    var body: some View {
        Group {
            Section {
                Value1Cell(text: "Pocket", detailText: Pocket.berry.title(forGame: game), image: nil)
                Value1Cell(text: "Introduced", detailText: item.generationIntroduced.title)
            }
        }
    }

}

private struct ItemPriceCell: View {

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
                    .scaledToFit()
                    .frame(height: UIFont.preferredFont(forTextStyle: .body).pointSize)
                Text("\(price)")
                    .fixedSize(horizontal: true, vertical: true)
            }
        }
        .monospacedBody()
        .contentShape(Rectangle())
    }

}

private extension Generation {

    var priceSprite: Image {
        Image("Price/generation\(rawValue)")
    }

}
