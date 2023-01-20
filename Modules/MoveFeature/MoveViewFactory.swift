//
//  MoveViewFactory.swift
//  
//
//  Created by Daniel Byon on 10/5/22.
//

import PokedexCore
import SwiftUI

public protocol MoveViewFactory {

    associatedtype TypeEffectivenessView: View

    func makeTypeEffectivenessView(primaryType: PokemonType, secondaryType: PokemonType?, kind: TypeEffectiveness.Kind, game: Game) -> TypeEffectivenessView

}

struct MockMoveViewFactory: MoveViewFactory {

    func makeTypeEffectivenessView(primaryType: PokemonType, secondaryType: PokemonType?, kind: TypeEffectiveness.Kind, game: Game) -> some View {
        EmptyView()
    }

}
