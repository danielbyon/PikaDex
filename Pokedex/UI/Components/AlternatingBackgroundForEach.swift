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

    var body: some View {
        ForEach(data.indices, id: \.self) { i in
            self.content(self.data[i])
                .conditionalModifier(self.data.distance(from: self.data.startIndex, to: i) % 2 == 1) {
                    $0.listRowBackground(Color(self.colorScheme == .dark ? UIColor.tertiarySystemBackground : UIColor.systemGray5))
            }
        }
    }

    init(_ data: Data, content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.content = content
    }

}

struct AlternatingBackgroundForEach_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            List {
                AlternatingBackgroundForEach(["1", "2", "3", "4", "5"]) {
                    Text($0)
                }
            }
            List {
                AlternatingBackgroundForEach(["1", "2", "3", "4", "5"]) {
                    Text($0)
                }
            }
            .colorScheme(.dark)
        }
    }
}
