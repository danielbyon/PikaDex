//
//  LocationDetailPokemonCell.swift
//  
//
//  Created by Daniel Byon on 10/19/22.
//

import PokedexUI
import SwiftUI

struct LocationDetailPokemonCell: View {

    let row: LocationAreaViewModel.Row

    var body: some View {
        VStack(alignment: .leading) {
            PokemonCell(pokemon: row.pokemon, pokedex: .national)

            VStack(alignment: .leading, spacing: 8.0) {
                ForEach(row.items, id: \.self) { item in
                    BadgeCell(item: item)
                }
            }
            .padding(.bottom, 8.0)
        }
    }

}

//struct LocationDetailPokemonCell_Previews: PreviewProvider {
//    static var previews: some View {
//        LocationDetailPokemonCell()
//    }
//}

private extension BadgeCell {

    init(item: LocationAreaViewModel.Item) {
        self.init(
            title: item.title,
            subtitle: item.subtitle,
            image: nil,
            badge: .init(encounterRate: item.encounterRate)
        )
    }

}
