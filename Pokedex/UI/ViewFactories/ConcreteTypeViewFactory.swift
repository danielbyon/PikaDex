//
//  ConcreteTypeViewFactory.swift
//  Pokedex
//
//  Created by Daniel Byon on 10/10/22.
//  Copyright © 2022 Daniel Byon. All rights reserved.
//

import PokedexCore
import PokemonFeature
import SwiftUI
import TypeFeature

struct ConcreteTypeViewFactory: TypeViewFactory {

    func makeTypeEffectivenessView(primaryType: PokemonType, secondaryType: PokemonType?, kind: TypeEffectiveness.Kind, game: Game) -> some View {
        PokemonTypeEffectiveness(primaryType: primaryType, secondaryType: secondaryType, kind: kind, game: game)
    }

}
