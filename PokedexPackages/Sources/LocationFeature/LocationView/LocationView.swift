//
//  LocationView.swift
//  
//
//  Created by Daniel Byon on 10/17/22.
//

import PokedexUI
import SwiftUI

public struct LocationView: View {

    private let location: Location

    @Query private var locationPokemons: QueryResults<LocationPokemon>
    @State private var selectedSegment: Segment = .byArea
    @State private var selectedMap: LocationMap?

    enum Segment: String, CaseIterable, Identifiable {

        case byArea = "By Area"
        case byCaptureMethod = "By Capture Method"

        var id: String { rawValue }

    }

    public var body: some View {
        List {
            LocationInfoSection(location: location)

            if !location.maps.isEmpty {
                LocationMapsSection(maps: location.maps, selectedMap: $selectedMap)
            }

            if !locationPokemons.isEmpty {
                LocationPokemonSection(
                    areaViewModel: .init(
                        location: location,
                        locationPokemons: locationPokemons
                    ),
                    captureMethodViewModel: .init(
                        location: location,
                        locationPokemons: locationPokemons
                    ),
                    selectedSegment: $selectedSegment
                )
            }

            if location.hasExternalLinks {
                LocationExternalLinks(location: location)
            }
        }
        .listStyle(.grouped)
        .navigationTitle(location.name)
        .sheet(item: $selectedMap) { map in
            NavigationStack {
                LocationMapView(map: map)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                HomeButton()
            }
        }
        .onAppear {
            $locationPokemons.wrappedValue = .init(location: location)
        }
    }

    public init(location: Location) {
        self.location = location
    }

}

struct LocationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationView(location: .galarMine)
    }
}
