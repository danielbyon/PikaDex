//
//  MoveBadges.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/9/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct MoveBadges: View {
    
    let move: Move
    let game: Game
    
    var body: some View {
        VStack(spacing: 2.0) {
            Badge(pokemonType: move.type, equalWidths: true, isSmall: true)
            Badge(moveCategory: move.info.category, equalWidths: true, isSmall: true)
        }
    }

}

struct MoveBadges_Previews: PreviewProvider {
    static var previews: some View {
        MoveBadges(move: Move.generateThunderShock(), game: .sword)
    }
}
