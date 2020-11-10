//
//  PokemonImage.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/11/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI

struct PokemonImage: View {

    var form: PokemonForm
    var padding: CGFloat = 30.0

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(form.color.uiColor)
                    .opacity(0.85)
            )
            if let formImage = UIImage(named: form.imageName) {
                Image(uiImage: formImage)
                    .resizable()
                    .scaledToFit()
                    .padding(padding)
            }
        }
    }

}

struct PokemonImage_Previews: PreviewProvider {
    static var previews: some View {
        PokemonImage(form: Pokemon.generate(withName: "Venusaur", game: .letsGoPikachu).forms[1])
    }
}
