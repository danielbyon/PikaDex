//
//  SelectItem.swift
//  
//
//  Created by Daniel Byon on 10/31/22.
//

import PokedexUI
import SwiftUI

struct SelectItem<ViewFactory: TeamViewFactory>: View {

    let game: Game
    let currentItem: Item?
    let viewFactory: ViewFactory
    let onSelect: (Item?) -> Void

    @Environment(\.dismiss) private var dismiss
    @Query private var items: QueryResults<Item>

    var body: some View {
        SearchableList(
            items: items,
            query: $items.query,
            searchPrompt: "Search for an item",
            id: \.name
        ) { item in
            makeItemCell(item: item)
        }
        .toolbar {
            ToolbarItemGroup(placement: .destructiveAction) {
                Button(
                    "Remove Item",
                    role: .destructive
                ) {
                    onSelect(nil)
                    dismiss()
                }
                .disabled(currentItem == nil)
            }

        }
    }

    private func makeItemCell(item: Item) -> some View {
        HStack {
            viewFactory.makeItemCell(item: item)
            Spacer()
            if let currentItem,
               currentItem == item {
                Image(systemName: "checkmark")
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect(item)
            dismiss()
        }
    }

}

struct SelectItem_Previews: PreviewProvider {
    static var previews: some View {
        SelectItem(
            game: .sword,
            currentItem: nil,
            viewFactory: MockTeamViewFactory(),
            onSelect: { _ in }
        )
    }
}
