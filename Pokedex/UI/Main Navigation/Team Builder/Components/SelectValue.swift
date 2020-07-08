//
//  SelectValue.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/21/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct SelectValue: View {

    let range: Range<Int>
    let onSelect: (Int) -> Void

    var body: some View {
        List(range, id: \.self) { element in
            HStack {
                Text("\(element)")
                Spacer()
            }
            .monospacedBody()
            .contentShape(Rectangle())
            .onTapGesture {
                self.onSelect(element)
            }
        }
    }

    init(range: Range<Int>, onSelect: @escaping (Int) -> Void) {
        self.range = range
        self.onSelect = onSelect
    }

}

struct SelectValue_Previews: PreviewProvider {
    static var previews: some View {
        SelectValue(range: 0..<10, onSelect: { _ in })
    }
}
