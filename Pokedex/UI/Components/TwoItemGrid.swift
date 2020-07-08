//
//  TwoItemGrid.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/10/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct TwoItemGrid<A, B>: View where A: View, B: View {

    var item1: A
    var item2: B
    var spacing: CGFloat = 16.0

    var body: some View {
        HStack(alignment: .top, spacing: spacing) {
            item1
            item2
        }
    }

}

struct TwoItemGrid_Previews: PreviewProvider {
    static var previews: some View {
        TwoItemGrid(
            item1: Rectangle().fill(Color.green).overlay(Text("1")),
            item2: Rectangle().fill(Color.blue).overlay(Text("2")))
    }
}
