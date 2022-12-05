//
//  MoveTargetView.swift
//  
//
//  Created by Daniel Byon on 10/3/22.
//

import PokedexUI
import SwiftUI

struct MoveTargetView: View {

    var title: String
    var enabled: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4.0)
                .fill(Color(enabled ? PokemonColor.red.uiColor : PokemonColor.gray.uiColor))
                .opacity(0.7)
            Text(title)
                .monospacedBody()
                .padding(.vertical, 4.0)
        }
    }

}

struct MoveTargetView_Previews: PreviewProvider {
    static var previews: some View {
        MoveTargetView(
            title: "Self",
            enabled: true
        )
    }
}
