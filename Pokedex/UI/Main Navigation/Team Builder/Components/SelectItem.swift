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

    @FetchRequest var items: FetchedResults<Item>

    var body: some View {
        VStack {
            Card {
                HStack {
                    Text("None")
                        .monospacedBody()
                    Spacer()
                }
            }
            .contentShape(Rectangle())
            .padding()
            .onTapGesture {
                self.onSelect(nil)
            }

            SearchableList(viewModel: SearchableListViewModel(objects: items), searchPlaceholder: "Search for an item") { item in
                ItemCell(item: item).onTapGesture {
                    self.onSelect(item)
                }
            }
        }
        .navigationBarTitle("Items")
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
