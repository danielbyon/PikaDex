//
//  PokemonExternalLinks.swift
//  
//
//  Created by Daniel Byon on 11/5/22.
//

import PokedexUI
import SwiftUI

struct PokemonExternalLinks: View {

    let pokemon: PokemonDetail
    
    var body: some View {
        NavigationLink(value: Route.url(pokemon.bulbapediaURL)) {
            Text("View on Bulbapedia")
        }
        NavigationLink(value: Route.url(pokemon.pokemonDBURL)) {
            Text("View on Pokemon DB")
        }
    }

}

struct PokemonExternalLinks_Previews: PreviewProvider {
    static var previews: some View {
        PokemonExternalLinks(pokemon: .charizard)
    }
}
