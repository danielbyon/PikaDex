//
//  Item+Stub.swift
//  
//
//  Created by Daniel Byon on 10/20/22.
//

import Foundation

extension Item {

    public static var potion: Item {
        .init(
            name: "Potion",
            game: .sword,
            generationIntroduced: 1,
            type: .item,
            itemDescription: "Heals your shit",
            spriteName: "potion",
            info: .bag(
                .init(
                    itemDescription: "Heals your shit",
                    cost: nil,
                    sell: nil,
                    pocket: .medicine
                )
            ),
            bulbapediaURL: URL(string: "https://bulbapedia.bulbagarden.net/wiki/Potion")!,
            pokemonDBURL: nil
        )
    }

}
