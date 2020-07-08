//
//  ThreeItemGrid.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/23/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct ThreeItemGrid<A, B, C>: View where A: View, B: View, C: View {

    var item1: A
    var item2: B
    var item3: C
    var spacing: CGFloat = 16.0
    var largeItemOnLeftSide = true

    var body: some View {
        HStack(alignment: .top, spacing: spacing) {
            if largeItemOnLeftSide {
                item1
                VStack(alignment: .leading, spacing: spacing) {
                    item2
                    item3
                }
            } else {
                VStack(alignment: .leading, spacing: spacing) {
                    item1
                    item2
                }
                item3
            }
        }
    }

}

struct ThreeItemGrid_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ThreeItemGrid(
                item1: Rectangle().fill(Color.green).overlay(Text("1")),
                item2: Rectangle().fill(Color.blue).overlay(Text("2")),
                item3: Rectangle().fill(Color.red).overlay(Text("3")))

            ThreeItemGrid(
                item1: Rectangle().fill(Color.green).overlay(Text("1")),
                item2: Rectangle().fill(Color.blue).overlay(Text("2")),
                item3: Rectangle().fill(Color.red).overlay(Text("3")),
                largeItemOnLeftSide: false)
        }
    }
}
