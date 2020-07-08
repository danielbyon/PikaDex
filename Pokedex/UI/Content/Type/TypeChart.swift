//
//  TypeChart.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/4/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct TypeChart: View {

    var body: some View {
        VStack(spacing: 0) {
            ForEach(PokemonType.allCases) { rowType in
                HStack(spacing: 5) {
                    Badge(title: rowType.abbreviation, fillColor: rowType.color, isSmall: true)
                    ForEach(PokemonType.allCases) { column in
                        Rectangle()
                            .stroke(lineWidth: 1)
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }
                }
            }
        }
    }

}

struct TypeChart_Previews: PreviewProvider {
    static var previews: some View {
        TypeChart()
    }
}

private extension VerticalAlignment {

    private enum TypeAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[VerticalAlignment.center]
        }
    }

    static let typeAlignment = VerticalAlignment(TypeAlignment.self)

}
