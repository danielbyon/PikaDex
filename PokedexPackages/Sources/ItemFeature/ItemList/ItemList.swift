//
//  ItemList.swift
//  
//
//  Created by Daniel Byon on 10/20/22.
//

import PokedexUI
import SwiftUI

public struct ItemList: View {

    @Query private var items: QueryResults<Item>

    private let game: Game

    public var body: some View {
        SearchableList(
            items: items,
            query: $items.query,
            searchPrompt: "Search for an item",
            id: \.name
        ) { item in
            NavigationLink(value: Route.content(.item(item))) {
                ItemCell(item: item)
            }
        }
        .navigationTitle("Items")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                HomeButton()
            }
        }
        .onAppear {
            $items.wrappedValue = .init(game: game)
        }
    }

    public init(game: Game) {
        self.game = game
    }

}

struct ItemList_Previews: PreviewProvider {
    static var previews: some View {
        PreviewContainer {
            ItemList(game: .sword)
        }
    }
}
