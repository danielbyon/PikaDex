//
//  SelectItem.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/21/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct SelectItem: View {

    let game: Game
    let onSelect: (Item?) -> Void

    @Environment(\.dismiss) var dismiss
    @FetchRequest var items: FetchedResults<Item>
    
    var body: some View {
        SearchableList(objects: items, searchPlaceholder: "Search for an item") { item in
            HStack {
                ItemCell(item: item)
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                self.onSelect(item)
                self.dismiss()
            }
        }
        .toolbar {
            ToolbarItem {
                Button("Remove Item") {
                    self.onSelect(nil)
                    self.dismiss()
                }
            }
        }
        .navigationTitle("Items")
    }

    init(game: Game, onSelect: @escaping (Item?) -> Void) {
        self.game = game
        self.onSelect = onSelect
        self._items = FetchRequest(fetchRequest: Item.allFetchRequest(for: game), animation: .default)
    }
}

struct SelectItem_Previews: PreviewProvider {
    static var previews: some View {
        SelectItem(game: .sword, onSelect: { _ in })
    }
}
