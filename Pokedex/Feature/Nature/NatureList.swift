//
//  NatureList.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/23/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import PokedexUI
import SwiftUI

public struct NatureList: View {

    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    private var natures: [NatureCellViewModel] { Nature.all.map { .init(nature: $0) } }
    private var numberOfColumns: Int { horizontalSizeClass == .compact ? 2 : 4 }

    public var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: .init(spacing: 16.0), count: numberOfColumns), spacing: 16.0) {
                ForEach(natures) { nature in
                    NatureCell(viewModel: nature)
                }
            }
            .padding()
        }
        .navigationTitle("Natures")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                HomeButton()
            }
        }
    }

    public init() { }

}

struct NatureList_Previews: PreviewProvider {
    static var previews: some View {
        NatureList()
    }
}
