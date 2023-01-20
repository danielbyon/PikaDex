//
//  LocationCaptureMethodViewModel.swift
//  
//
//  Created by Daniel Byon on 10/19/22.
//

import PokedexCore
import SwiftUI

final class LocationCaptureMethodViewModel {

    let sections: [Section]

    struct Section {
        let title: String
        let subtitle: String
        let detail: String?
        let rows: [Row]
    }

    struct Row {
        let title: String
        let subtitle: String?
        let encounterRate: EncounterRate
        let spriteName: String
        let pokemon: Pokemon

        init(locationPokemon: LocationPokemon) {
            self.title = locationPokemon.pokemon.name
            if locationPokemon.levelLow < 0 {
                let count = abs(locationPokemon.levelLow)
                self.subtitle = String(repeating: "⭐︎", count: count)
            } else if locationPokemon.levelLow > 0 {
                var subtitle = "Lv. \(locationPokemon.levelLow)"
                if let levelHigh = locationPokemon.levelHigh {
                    subtitle += "-\(levelHigh)"
                }
                if let detail = locationPokemon.detail {
                    subtitle += " (\(detail))"
                }
                self.subtitle = subtitle
            } else {
                self.subtitle = locationPokemon.detail
            }
            self.encounterRate = locationPokemon.encounterRate
            self.spriteName = locationPokemon.pokemon.spriteName
            self.pokemon = locationPokemon.pokemon
        }
    }

    init(
        location: Location,
        locationPokemons: QueryResults<LocationPokemon>
    ) {
        var sections: [String: [LocationPokemon]] = [:]
        for item in locationPokemons {
            let sectionName = item.sectionName
            if var section = sections[sectionName] {
                section.append(item)
                sections[sectionName] = section
            } else {
                sections[sectionName] = [item]
            }
        }

        self.sections = sections
            .filter { !$0.value.isEmpty }
            .compactMap { _, items in
            let subtitle: String
            if items[0].encounterCondition == "none" {
                subtitle = items[0].captureMethod.rawValue
            } else {
                subtitle = "\(items[0].captureMethod.rawValue) (\(items[0].encounterCondition))"
            }
            let rows = items
                .sorted {
                    if $0.encounterRate == $1.encounterRate {
                        return $0.pokemon.name < $1.pokemon.name
                    } else {
                        return $0.encounterRate > $1.encounterRate
                    }
                }
                .map(Row.init)
            guard !rows.isEmpty else { return nil }
            return Section(
                title: items[0].area,
                subtitle: subtitle,
                detail: items[0].timeOfDay?.concatenatedRawValues,
                rows: rows
            )
        }.sorted()
    }

}

extension LocationCaptureMethodViewModel.Section: Comparable {

    static func < (lhs: LocationCaptureMethodViewModel.Section, rhs: LocationCaptureMethodViewModel.Section) -> Bool {
        if lhs.title == rhs.title {
            if lhs.subtitle == rhs.subtitle {
                return lhs.detail ?? "" < rhs.detail ?? ""
            } else {
                return lhs.subtitle < rhs.subtitle
            }
        } else {
            return lhs.title < rhs.title
        }
    }

}

extension LocationCaptureMethodViewModel.Section: Hashable { }

extension LocationCaptureMethodViewModel.Section: Identifiable {

    var id: String { title + subtitle + (detail ?? "") }

}

extension LocationCaptureMethodViewModel.Row: Comparable {

    static func < (lhs: LocationCaptureMethodViewModel.Row, rhs: LocationCaptureMethodViewModel.Row) -> Bool {
        if lhs.title == rhs.title {
            return lhs.subtitle ?? "" < rhs.subtitle ?? ""
        } else {
            return lhs.title < rhs.title
        }
    }

}

extension LocationCaptureMethodViewModel.Row: Hashable { }

extension LocationCaptureMethodViewModel.Row: Identifiable {

    var id: String { title + (subtitle ?? "") }

}

private extension LocationPokemon {

    var subtitle: String { "\(captureMethod) (\(encounterRate.string))" }

    var sectionName: String {
        [area,
         captureMethod.rawValue,
         encounterCondition,
         timeOfDay?.concatenatedRawValues
        ].compactMap { $0 }
            .joined(separator: " ")
    }

}

private extension Array where Self.Element == TimeOfDay {

    var concatenatedRawValues: String {
        map { $0.rawValue }.joined(separator: ", ")
    }

}
