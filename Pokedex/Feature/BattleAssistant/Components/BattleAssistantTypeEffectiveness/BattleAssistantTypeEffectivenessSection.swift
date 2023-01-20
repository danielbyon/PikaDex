//
//  BattleAssistantTypeEffectivenessSection.swift
//  
//
//  Created by Daniel Byon on 10/26/22.
//

import PokedexUI
import SwiftUI

struct BattleAssistantTypeEffectivenessSection: View {

    let title: String
    let types: [BattleAssistantTypeEffectivenessViewModel.CellViewModel]

    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    private var numberOfColumns: Int { horizontalSizeClass == .regular ? 6 : 3 }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .monospacedBody()
            LazyVGrid(columns: .init(repeating: .init(), count: numberOfColumns), spacing: 8.0) {
                ForEach(types) { cellViewModel in
                    PokemonTypeEffectivenessCell(
                        type: cellViewModel.type,
                        value: cellViewModel.value,
                        equalWidths: true,
                        isSmall: false
                    )
                }
            }
        }
    }

}

struct BattleAssistantTypeEffectivenessSection_Previews: PreviewProvider {
    static var previews: some View {
        BattleAssistantTypeEffectivenessSection(
            title: "Recommended",
            types: [
                .init(type: .fire, value: 2.0)
            ]
        )
    }
}
