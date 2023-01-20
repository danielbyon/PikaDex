//
//  SelectNature.swift
//  
//
//  Created by Daniel Byon on 11/1/22.
//

import PokedexUI
import SwiftUI

struct SelectNature: View {

    let onSelect: (Nature) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: .init(spacing: 16.0), count: 2), spacing: 16.0) {
                ForEach(Nature.all) { nature in
                    NatureCell(viewModel: .init(nature: nature))
                        .onTapGesture {
                            self.onSelect(nature)
                            self.dismiss()
                        }
                }
            }
            .padding()
        }
        .navigationTitle("Natures")
    }

}

struct SelectNature_Previews: PreviewProvider {
    static var previews: some View {
        SelectNature(
            onSelect: { _ in }
        )
    }
}
