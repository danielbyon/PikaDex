//
//  ConcreteMoveViewFactory.swift
//  Pokedex
//
//  Created by Daniel Byon on 10/5/22.
//  Copyright © 2022 Daniel Byon. All rights reserved.
//

import MoveFeature
import PokemonFeature
import SwiftUI

struct ConcreteMoveViewFactory: MoveViewFactory {

    func makeTypeEffectivenessView(primaryType: PokemonType, secondaryType: PokemonType?, kind: TypeEffectiveness.Kind, game: Game) -> some View {
        PokemonTypeEffectiveness(primaryType: primaryType, secondaryType: secondaryType, kind: kind, game: game)
    }

}
