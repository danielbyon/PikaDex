//
//  DualTypeCheckerViewFactory.swift
//  
//
//  Created by Daniel Byon on 10/22/22.
//

import PokedexCore
import SwiftUI

public protocol DualTypeCheckerViewFactory {

    associatedtype TypeEffectivenessView: View

    func makeTypeEffectivenessView(primaryType: PokemonType, secondaryType: PokemonType?, kind: TypeEffectiveness.Kind, game: Game) -> TypeEffectivenessView

}

struct MockDualTypeCheckerViewFactory: DualTypeCheckerViewFactory {

    func makeTypeEffectivenessView(primaryType: PokemonType, secondaryType: PokemonType?, kind: TypeEffectiveness.Kind, game: Game) -> some View {
        EmptyView()
    }

}
