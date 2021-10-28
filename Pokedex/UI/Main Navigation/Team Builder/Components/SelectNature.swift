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

    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: .init(spacing: 16.0), count: 2), spacing: 16.0) {
                ForEach(Nature.all) { nature in
                    NatureCell(viewModel: .init(nature: nature)).onTapGesture {
                        self.onSelect(nature)
                        self.dismiss()
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Natures")
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
