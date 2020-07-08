//
//  ContentView.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/11/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        PokedexTab()
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .injectDependencies()
    }
}
