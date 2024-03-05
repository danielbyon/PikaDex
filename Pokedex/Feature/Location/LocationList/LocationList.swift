//
//  LocationList.swift
//  
//
//  Created by Daniel Byon on 10/17/22.
//

import PokedexUI
import SwiftUI

public struct LocationList: View {

    @Query private var locations: QueryResults<Location>

    private let game: Game

    public var body: some View {
        SearchableList(
            items: locations,
            query: $locations.query.toString(),
            searchPrompt: "Search for a location",
            id: \.name
        ) { location in
            NavigationLink(value: Route.content(.location(location))) {
                LocationCell(location: location)
            }
        }
        .navigationTitle("Locations")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                HomeButton()
            }
        }
        .onAppear {
            $locations.wrappedValue = .init(game: game)
        }
    }

    public init(game: Game) {
        self.game = game
    }

}

struct LocationList_Previews: PreviewProvider {
    static var previews: some View {
        LocationList(game: .sword)
    }
}
