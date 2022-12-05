//
//  ItemView.swift
//  
//
//  Created by Daniel Byon on 10/20/22.
//

import PokedexUI
import SwiftUI

public struct ItemView: View {

    let item: Item

    public var body: some View {
        List {
            Section {
                DescriptionCell(text: item.itemDescription)
            }

            switch item.info {
            case .bag(let info):
                ItemBagInfoView(
                    info: info,
                    game: item.game,
                    generationIntroduced: item.generationIntroduced
                )
            case .berry(let info):
                ItemBerryInfoView(
                    info: info,
                    game: item.game,
                    generationIntroduced: item.generationIntroduced
                )
            }

            Section {
                NavigationLink(value: Route.url(item.bulbapediaURL)) {
                    Text("View on Bulbapedia")
                }
                if let pokemonDBURL = item.pokemonDBURL {
                    NavigationLink(value: Route.url(pokemonDBURL)) {
                        Text("View on Pokemon DB")
                    }
                }
            } header: {
                SectionHeader("External Links")
            } footer: {
                ExternalLinksDisclaimer()
            }
        }
        .listStyle(.grouped)
        .navigationTitle(item.name)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                HomeButton()
            }
        }
    }

    public init(item: Item) {
        self.item = item
    }

}

struct ItemView_Previews: PreviewProvider {
    static var previews: some View {
        ItemView(item: .potion)
    }
}
