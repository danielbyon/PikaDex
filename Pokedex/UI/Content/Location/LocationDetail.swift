//
//  LocationDetail.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/11/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI
import Combine

struct LocationDetail: View {
    
    let location: Location
    let game: Game
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @FetchRequest private var locationPokemons: FetchedResults<LocationPokemon>
    @State private var selectedSegment: Segment = .byArea
    @State private var selectedMap: LocationMap?
    
    private var hasPokemon: Bool { !locationPokemons.isEmpty }
    
    private var viewModel: LocationDetailViewModel {
        LocationDetailViewModel(location: location, locationPokemons: Array(locationPokemons))
    }
    
    private var currentTitle: String { selectedSegment.rawValue }
    private var mapPreviewHeight: CGFloat { horizontalSizeClass == .regular ? 200.0 : 120.0 }
    private var mapPreviewPadding: CGFloat { 8.0 }
    private var pokemonViewModel: LocationPokemonsViewModel {
        LocationPokemonsViewModel(locationPokemons: Array(locationPokemons), game: game)
    }
    
    var body: some View {
        List {
            Section {
                Value1Cell(text: "Name", detailText: location.name)
                BadgeCell(title: "Region", badge: Badge(region: location.region))
            }
            
            if !viewModel.maps.isEmpty {
                Section(header: SectionHeader("Maps")) {
                    AlternatingBackgroundForEach(viewModel.maps) { map in
                        VStack {
                            Text(map.areaName)
                                .monospacedBody()
                            LocationMapPreview(map: map)
                                .frame(height: self.mapPreviewHeight)
                        }
                        .padding(.vertical, self.mapPreviewPadding)
                        .onTapGesture {
                            self.selectedMap = map
                        }
                    }
                }
            }
            
            if hasPokemon {
                Section(header: SectionHeader("Pokémon")) {
                    SegmentedControl(selectedSegment: $selectedSegment)
                }
                
                switch selectedSegment {
                case .byArea:
                    ForEach(viewModel.sections) { section in
                        Section(header: SectionHeader(section.title)) {
                            AlternatingBackgroundForEach(section.items) { item in
                                NavigationLink(destination: PokemonDetail(pokemon: item.pokemon, game: self.game)) {
                                    LocationDetailPokemonCell(item: item, game: self.game)
                                }
                            }
                        }
                    }
                case .byCaptureMethod:
                    ForEach(pokemonViewModel.sections) { section in
                        Section(header: LocationSectionHeader(section: section)) {
                            ForEach(section.items) { item in
                                NavigationLink(destination: item.destination) {
                                    BadgeCell(viewModel: item)
                                }
                            }
                        }
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle(location.name)
        .sheet(item: $selectedMap) { map in
            NavigationView {
                LocationMapDetail(map: map)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    private enum Segment: String, CaseIterable, Identifiable {
        
        case byArea = "By Area"
        case byCaptureMethod = "By Capture Method"
        
        var id: String { rawValue }
        
    }
    
    init(location: Location, game: Game) {
        self.location = location
        self.game = game
        self._locationPokemons = FetchRequest(fetchRequest: LocationPokemon.fetchRequest(for: location, game: game))
    }
    
}

struct LocationDetail_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                LocationDetail(location: Location.generateLocation(withName: "Route 25", region: .kanto, game: .red), game: .red)
            }
            NavigationView {
                LocationDetail(location: Location.generateLocation(withName: "Route 25", region: .kanto, game: .red), game: .red)
            }
            .environment(\.colorScheme, .dark)
        }
        .injectDependencies()
    }
}

private extension BadgeCell {
    
    init(viewModel: LocationDetailViewModel.ViewModel) {
        self.init(
            title: viewModel.title,
            subtitle: viewModel.subtitle,
            image: nil,
            badge: viewModel.badge)
    }
    
    init(viewModel: LocationPokemonViewModel) {
        self.init(
            title: viewModel.title,
            subtitle: viewModel.subtitle,
            image: viewModel.image,
            badge: viewModel.badge)
    }
    
}

private struct LocationDetailViewModel {
    
    let maps: [LocationMap]
    let sections: [Section]
    
    struct Section {
        let title: String
        let items: [Item]
    }
    
    struct Item {
        let pokemon: StoredPokemon
        let viewModels: [ViewModel]
    }
    
    struct ViewModel {
        
        let title: String
        let subtitle: String?
        let badge: Badge
        
        init(locationPokemon: LocationPokemon) {
            self.title = locationPokemon.encounterRateString
            self.subtitle = locationPokemon.levelRangeWithDetail
            self.badge = Badge(encounterRate: locationPokemon.encounterRate)
        }
        
    }
    
    init<T>(location: Location, locationPokemons: T) where T: RandomAccessCollection, T.Element == LocationPokemon {
        self.maps = location.maps.filter { $0.image != nil }
        
        let missingMaps = location.maps.filter { $0.image == nil }
        if !missingMaps.isEmpty {
            print("Location \(location.name) has missing maps!: \(missingMaps)")
        }
        
        var transforms: [String: [StoredPokemon: [LocationPokemon]]] = [:]
        locationPokemons.forEach { locationPokemon in
            let area = locationPokemon.area
            let pokemon = locationPokemon.pokemon
            if var existingArea = transforms[area] {
                if var existingPokemon = existingArea[pokemon] {
                    existingPokemon.append(locationPokemon)
                    existingArea[pokemon] = existingPokemon
                } else {
                    existingArea[pokemon] = [locationPokemon]
                }
                transforms[area] = existingArea
            } else {
                transforms[area] = [locationPokemon.pokemon: [locationPokemon]]
            }
        }
        
        self.sections = transforms
            .map { area, areaPokemon in
                var items: [Item] = areaPokemon.map { pokemon, locationPokemons in
                    let viewModels: [ViewModel] = locationPokemons
                        .map {  ViewModel(locationPokemon: $0) }
                        .sorted {
                            if $0.title == $1.title {
                                return $0.subtitle ?? "" < $1.subtitle ?? ""
                            } else {
                                return $0.title < $1.title
                            }
                        }
                    return Item(pokemon: pokemon, viewModels: viewModels)
                }
                items.sort { $0.pokemon.index < $1.pokemon.index }
                
                let title = "\(area) Area Pokémon"
                return Section(title: title, items: items)
            }
            .sorted { $0.title < $1.title }
    }
    
}

extension LocationDetailViewModel.Section: Identifiable {
    
    var id: String { title + items.map { $0.id }.joined() }
    
}

extension LocationDetailViewModel.Item: Identifiable {
    
    var id: String { pokemon.name + viewModels.map { $0.id }.joined() }
    
}

extension LocationDetailViewModel.ViewModel: Identifiable {
    
    var id: String { title + (subtitle ?? "") + badge.title }
    
}

private struct LocationDetailPokemonCell: View {
    
    let item: LocationDetailViewModel.Item
    let game: Game
    
    var body: some View {
        VStack(alignment: .leading) {
            PokemonFormCellInfo(form: item.pokemon.defaultForm, game: game, showsFormName: false)
            VStack(alignment: .leading, spacing: 8.0) {
                ForEach(item.viewModels) { viewModel in
                    BadgeCell(viewModel: viewModel)
                }
            }
            .padding(.bottom, 8.0)
        }
    }
    
}
