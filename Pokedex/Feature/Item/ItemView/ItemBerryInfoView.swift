//
//  ItemBerryInfoView.swift
//  
//
//  Created by Daniel Byon on 10/21/22.
//

import PokedexUI
import SwiftUI

struct ItemBerryInfoView: View {

    let info: Item.BerryInfo
    let game: Game
    let generationIntroduced: Generation

    var body: some View {
        Section {
            Value1Cell(text: "Pocket", detailText: Pocket.berry.title(forGame: game))
            Value1Cell(text: "Introduced", detailText: generationIntroduced.title)
        }
    }

}

struct ItemBerryInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ItemBerryInfoView(
            info: .init(
                itemDescription: "Berries bitch!",
                sizeInCm: 2.5,
                firmness: .hard,
                bitter: 0,
                dry: 1,
                sour: 0,
                spicy: 0,
                sweet: 1
            ),
            game: .sword,
            generationIntroduced: 3
        )
    }
}
