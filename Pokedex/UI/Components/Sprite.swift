//
//  Sprite.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/17/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct Sprite: View {

    let spriteName: String
    let width: CGFloat?

    var body: some View {
        Image(spriteName)
            .interpolation(.none)
            .renderingMode(.original)
            .sprite(width: width)
    }

    init(_ spriteName: String, width: CGFloat? = 40.0) {
        self.spriteName = spriteName
        self.width = width
    }

}

struct Sprite_Previews: PreviewProvider {
    static var previews: some View {
        Sprite("rare-candy")
    }
}

extension Image {

    func sprite(width: CGFloat?) -> some View {
        resizable()
            .scaledToFit()
            .frame(width: width, height: width)
    }

}
