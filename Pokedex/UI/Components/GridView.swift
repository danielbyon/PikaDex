//
//  GridView.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/14/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct GridView<Element, Content>: View where Element: Identifiable, Content: View {

    var elements: [Element]
    var numberOfItemsPerRow: Int
    var spacing: UIOffset = UIOffset(horizontal: 16.0, vertical: 16.0)
    var content: (Element) -> Content

    var items: [[Element]] {
        stride(from: elements.startIndex, to: elements.endIndex, by: numberOfItemsPerRow)
            .map { Array(elements.dropFirst($0).prefix(numberOfItemsPerRow)) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: spacing.vertical) {
            ForEach(0..<items.count, id: \.self) { i in
                HStack(alignment: .top, spacing: self.spacing.horizontal) {
                    ForEach(0..<self.items[i].count, id: \.self) { j in
                        self.content(self.items[i][j])
                    }
                }
            }
        }
    }

}

struct GridView_Previews: PreviewProvider {
    static var previews: some View {
        GridView(
            elements: ["One", "Two", "Three", "Four"],
            numberOfItemsPerRow: 2) {
                Text($0)
        }
    }
}
