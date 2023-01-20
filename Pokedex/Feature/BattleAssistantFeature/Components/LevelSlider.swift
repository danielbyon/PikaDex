//
//  LevelSlider.swift
//  
//
//  Created by Daniel Byon on 10/23/22.
//

import PokedexUI
import SwiftUI

struct LevelSlider: View {

    @Binding var level: Double

    var body: some View {
        HStack {
            Text("Level")
            Slider(value: $level, in: 1...100, step: 1.0) {
                EmptyView()
            }
            Text("\(Int(level))")
        }
        .monospacedBody()
        .foregroundColor(.primary)
    }

}

struct LevelSlider_Previews: PreviewProvider {
    @State private static var level = 50.0

    static var previews: some View {
        LevelSlider(level: $level)
    }
}
