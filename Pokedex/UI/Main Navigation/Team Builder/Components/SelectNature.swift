//
//  SelectNature.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/21/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct SelectNature: View {

    let onSelect: (Nature) -> Void

    var body: some View {
        ScrollView {
            GridView(elements: Nature.all, numberOfItemsPerRow: 2) { nature in
                NatureCell(viewModel: .init(nature: nature)).onTapGesture {
                    self.onSelect(nature)
                }
            }
            .padding()
        }
        .navigationBarTitle("Natures")
    }

    init(onSelect: @escaping (Nature) -> Void) {
        self.onSelect = onSelect
    }

}

struct SelectNature_Previews: PreviewProvider {
    static var previews: some View {
        SelectNature(onSelect: { _ in })
    }
}
