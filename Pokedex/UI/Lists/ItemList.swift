//
//  ItemList.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/26/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct ItemList: View {

    let game: Game

    @FetchRequest var items: FetchedResults<Item>

    var body: some View {
        SearchableList(objects: items, searchPlaceholder: "Search for an item") { item in
            NavigationLink(destination: ItemDetail(item: item, game: self.game)) {
                ItemCell(item: item)
            }
        }
        .navigationTitle("Items")
    }

    init(game: Game) {
        self.game = game
        self._items = FetchRequest(fetchRequest: Item.allFetchRequest(for: game), animation: .default)
    }

}

struct ItemList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ItemList(game: .sword)
        }
        .injectDependencies()
    }
}
