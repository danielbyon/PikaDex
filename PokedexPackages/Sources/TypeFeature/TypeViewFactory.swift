//
//  TypeViewFactory.swift
//  
//
//  Created by Daniel Byon on 10/10/22.
//

import PokedexCore
import SwiftUI

public protocol TypeViewFactory {

    associatedtype TypeEffectivenessView: View

    func makeTypeEffectivenessView(primaryType: PokemonType, secondaryType: PokemonType?, kind: TypeEffectiveness.Kind, game: Game) -> TypeEffectivenessView

}

struct MockTypeViewFactory: TypeViewFactory {

    func makeTypeEffectivenessView(primaryType: PokemonType, secondaryType: PokemonType?, kind: TypeEffectiveness.Kind, game: Game) -> some View {
        EmptyView()
    }

}
