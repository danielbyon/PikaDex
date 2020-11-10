//
//  LocationList.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/11/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct LocationList: View {

    let game: Game

    @FetchRequest var locations: FetchedResults<Location>

    var body: some View {
        SearchableList(viewModel: SearchableListViewModel(objects: locations), searchPlaceholder: "Search for a location") { location in
            NavigationLink(destination: LocationDetail(location: location, game: self.game)) {
                LocationCell(location: location)
            }
        }
        .navigationTitle("Locations")
    }

    init(game: Game) {
        self.game = game
        self._locations = FetchRequest(fetchRequest: Location.allFetchRequest(for: game), animation: .default)
    }

}

struct LocationList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LocationList(game: .sword)
                .injectDependencies()
        }
    }
}
