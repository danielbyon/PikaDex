//
//  BattleAssistantLevelSlider.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/22/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct BattleAssistantLevelSlider: View {

    @Binding var level: Double

    var body: some View {
        HStack {
            Text("Level")
            Slider(value: $level, in: 1...100, step: 1.0, onEditingChanged: { _ in }) {
                EmptyView()
            }
            Text("\(Int(level))")
        }
        .monospacedBody()
        .foregroundColor(.primary)
    }

}

struct BattleAssistantLevelSlider_Previews: PreviewProvider {
    static var previews: some View {
        BattleAssistantLevelSlider(level: .constant(50))
    }
}
