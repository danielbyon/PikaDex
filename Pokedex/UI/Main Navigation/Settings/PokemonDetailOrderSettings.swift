//
//  PokemonDetailOrderSettings.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/11/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import AppSupport
import SwiftUI

struct PokemonDetailOrderSettings: View {

    @StateObject private var ordering = PokemonDetailOrdering()

    private var footerText: String {
        #if targetEnvironment(macCatalyst)
        let action = "Click"
        #else
        let action = "Tap"
        #endif
        return "\(action) the Edit button to change the ordering of the sections on the Pokemon Detail screen."
    }

    var body: some View {
        List {
            Section {
                Text("Header")
                ForEach(ordering.sections, id: \.self) { section in
                    Text(section.rawValue)
                }
                .onMove(perform: ordering.update)
            } footer: {
                Text(footerText)
                    .monospacedCaption()
            }
        }
        .navigationTitle("Pokémon Detail Ordering")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Reset", action: reset)
                EditButton()
            }
        }
    }

    private func reset() {
        withAnimation {
            ordering.reset()
        }
    }

}

struct PokemonDetailOrderSettings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PokemonDetailOrderSettings()
        }
    }
}
