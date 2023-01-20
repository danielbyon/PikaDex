//
//  LocationPokemonSection.swift
//  
//
//  Created by Daniel Byon on 10/19/22.
//

import PokedexUI
import SwiftUI

struct LocationPokemonSection: View {

    let areaViewModel: LocationAreaViewModel
    let captureMethodViewModel: LocationCaptureMethodViewModel

    @Binding var selectedSegment: LocationView.Segment

    var body: some View {
        Section {
            SegmentedControl(selectedSegment: $selectedSegment)
        } header: {
            SectionHeader("Pokémon")
        }

        switch selectedSegment {
        case .byArea:
            ForEach(areaViewModel.sections) { section in
                Section {
                    ForEach(section.rows) { row in
                        NavigationLink(value: Route.content(.pokemon(
                            row.pokemon,
                            pokedex: .national,
                            previousPokemonProvider: nil,
                            nextPokemonProvider: nil
                        ))) {
                            LocationDetailPokemonCell(row: row)
                        }
                    }
                } header: {
                    SectionHeader(section.title)
                }
            }
        case .byCaptureMethod:
            ForEach(captureMethodViewModel.sections) { section in
                Section {
                    ForEach(section.rows) { row in
                        NavigationLink(value: Route.content(.pokemon(
                            row.pokemon,
                            pokedex: .national,
                            previousPokemonProvider: nil,
                            nextPokemonProvider: nil
                        ))) {
                            BadgeCell(row: row)
                        }
                    }
                } header: {
                    CaptureMethodSectionHeader(section: section)
                }
            }
        }
    }

}

extension BadgeCell {

    init(row: LocationCaptureMethodViewModel.Row) {
        self.init(
            title: row.title,
            subtitle: row.subtitle,
            image: UIImage(named: row.spriteName),
            badge: Badge(encounterRate: row.encounterRate)
        )
    }

}
