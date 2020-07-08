//
//  ItemSprite.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/17/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct ItemSprite: View {

    let item: Item

    var body: some View {
        Sprite(item.spriteName, width: 24.0)
    }
    
}

struct ItemSprite_Previews: PreviewProvider {
    static var previews: some View {
        ItemSprite(item: Item.generateAntidote())
    }
}
