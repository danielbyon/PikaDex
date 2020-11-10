//
//  AlternatingBackgroundForEach.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/2/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct AlternatingBackgroundForEach<Data, Content>: View, DynamicViewContent where
    Data: RandomAccessCollection,
    Data.Element: Identifiable,
    Data.Index: Hashable,
    Content: View {

    var data: Data
    var content: (Data.Element) -> Content

    @Environment(\.colorScheme) var colorScheme

    private var backgroundColor: Color {
        Color(self.colorScheme == .dark ? UIColor.tertiarySystemBackground : UIColor.systemGray5)
    }

    var body: some View {
        ForEach(data.indices, id: \.self) { i in
            self.content(self.data[i])
                .if(self.data.distance(from: self.data.startIndex, to: i) % 2 == 1) {
                    $0.listRowBackground(backgroundColor)
                }
        }
    }

    init(_ data: Data, content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.content = content
    }

}

struct AlternatingBackgroundForEach_Previews: PreviewProvider {

    private struct Model: Identifiable {

        let value: String

        var id: String { value }

        init(_ value: String) {
            self.value = value
        }

    }

    static var previews: some View {
        Group {
            List {
                AlternatingBackgroundForEach([Model("1"), Model("2"), Model("3"), Model("4"), Model("5")]) {
                    Text($0.value)
                }
            }
            List {
                AlternatingBackgroundForEach([Model("1"), Model("2"), Model("3"), Model("4"), Model("5")]) {
                    Text($0.value)
                }
            }
            .colorScheme(.dark)
        }
    }
}
