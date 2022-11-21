//
//  ConcreteDualTypeCheckerViewFactory.swift
//  Pokedex
//
//  Created by Daniel Byon on 10/22/22.
//  Copyright © 2022 Daniel Byon. All rights reserved.
//

import DualTypeFeature
import PokedexUI
import PokemonFeature
import SwiftUI

struct ConcreteDualTypeCheckerViewFactory: DualTypeCheckerViewFactory {

    func makeTypeEffectivenessView(primaryType: PokemonType, secondaryType: PokemonType?, kind: TypeEffectiveness.Kind, game: Game) -> some View {
        PokemonTypeEffectiveness(primaryType: primaryType, secondaryType: secondaryType, kind: kind, game: game)
    }

}
