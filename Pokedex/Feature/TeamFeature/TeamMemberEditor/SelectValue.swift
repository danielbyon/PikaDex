//
//  SelectValue.swift
//  
//
//  Created by Daniel Byon on 10/31/22.
//

import PokedexUI
import SwiftUI

struct SelectValue: View {

    let range: Range<Int>
    let onSelect: (Int) -> Void

    @Environment(\.dismiss) var dismiss

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
                self.dismiss()
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
