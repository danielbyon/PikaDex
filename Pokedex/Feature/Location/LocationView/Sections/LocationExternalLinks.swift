//
//  LocationExternalLinks.swift
//  
//
//  Created by Daniel Byon on 11/6/22.
//

import PokedexUI
import SwiftUI

struct LocationExternalLinks: View {

    let location: Location

    var body: some View {
        Section {
            if let bulbapediaURL = location.bulbapediaURL {
                NavigationLink(value: Route.url(bulbapediaURL)) {
                    Text("View on Bulbapedia")
                }
            }
            if let pokemonDBURL = location.pokemonDBURL {
                NavigationLink(value: Route.url(pokemonDBURL)) {
                    Text("View on Pokemon DB")
                }
            }
        } header: {
            SectionHeader("External Links")
        } footer: {
            ExternalLinksDisclaimer()
        }
    }

}

struct LocationExternalLinks_Previews: PreviewProvider {
    static var previews: some View {
        LocationExternalLinks(location: .galarMine)
    }
}
