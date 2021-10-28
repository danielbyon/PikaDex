//
//  PokemonBaseStats.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/20/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI

struct PokemonBaseStats: View {
    
    let baseStats: Stats
    
    private var viewModels: [BaseStatViewModel] {
        BaseStatViewModel.makeViewModels(from: baseStats)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .statAlignment, spacing: 2) {
                ForEach(viewModels) { stat in
                    Text(stat.name + ":")
                        .alignmentGuide(.statAlignment, computeValue: { d in d[.trailing] })
                        .monospacedBody()
                }
            }
            .layoutPriority(1)
            
            VStack(alignment: .trailing, spacing: 2) {
                ForEach(viewModels) { stat in
                    Text("\(stat.value)")
                        .monospacedBody()
                }
            }
            .layoutPriority(1)
            
            VStack(alignment: .leading, spacing: 2) {
                ForEach(viewModels) { stat in
                    ProgressBar(progress: stat.fraction, color: stat.color, useRoundedProgress: true)
                }
            }
        }
    }

}

struct PokemonBaseStats_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PokemonBaseStats(baseStats: StoredPokemon.generateCharizard().defaultForm.baseStats)
        }
        .injectDependencies()
    }
}

// MARK: - HorizontalAlignment
private extension HorizontalAlignment {
    
    private enum StatAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[.leading]
        }
    }
    
    static let statAlignment = HorizontalAlignment(StatAlignment.self)
    
    private enum ValueAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            context[.trailing]
        }
    }
    
    static let valueAlignment = HorizontalAlignment(ValueAlignment.self)
    
}
