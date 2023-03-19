//
//  PokemonImage.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/11/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import PokedexUI
import SwiftUI

public struct PokemonImage: View {

    let imageName: String
    let bundle: Bundle?
    let backgroundColor: Color
    let padding: CGFloat

    public var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor.opacity(0.85))
            if let formImage = UIImage(named: imageName, in: bundle, with: nil) {
                Image(uiImage: formImage)
                    .resizable()
                    .scaledToFit()
                    .padding(padding)
            }
        }
    }

    public init(
        imageName: String,
        bundle: Bundle? = nil,
        backgroundColor: Color,
        padding: CGFloat = 30.0
    ) {
        self.imageName = imageName
        self.bundle = bundle
        self.backgroundColor = backgroundColor
        self.padding = padding
    }

    public init(form: PokemonDetailForm) {
        self.init(imageName: form.imageName, bundle: .resources, backgroundColor: Color(form.color.uiColor))
    }

}

struct PokemonImage_Previews: PreviewProvider {
    static var previews: some View {
        PokemonImage(imageName: "025-Pikachu", backgroundColor: .yellow)
    }
}
