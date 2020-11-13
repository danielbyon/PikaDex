//
//  PokemonDetailOrderSettings.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/11/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI
import AppSupport

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
            Section(footer: Text(footerText).monospacedCaption()) {
                Text("Header")
                ForEach(ordering.sections, id: \.self) { section in
                    Text(section.rawValue)
                }
                .onMove(perform: ordering.update)
            }
        }
        .navigationTitle("Pokémon Detail Ordering")
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
        NavigationView {
            PokemonDetailOrderSettings()
        }
        .injectDependencies()
    }
}
