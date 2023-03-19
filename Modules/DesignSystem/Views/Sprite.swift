//
//  Sprite.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/17/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import PokedexResources
import SwiftUI

public struct Sprite: View {

    let spriteName: String
    let bundle: Bundle?
    let width: CGFloat

    public var body: some View {
        Image(spriteName, bundle: bundle)
            .interpolation(.none)
            .renderingMode(.original)
            .sprite(width: width)
    }

    public init(
        _ spriteName: String,
        bundle: Bundle? = nil,
        width: CGFloat = 40.0
    ) {
        self.spriteName = spriteName
        self.bundle = bundle
        self.width = width
    }

}

struct Sprite_Previews: PreviewProvider {
    static var previews: some View {
        Sprite("rare-candy", bundle: .resources)
    }
}

private extension Image {

    func sprite(width: CGFloat?) -> some View {
        resizable()
            .scaledToFit()
            .frame(width: width, height: width)
    }

}
