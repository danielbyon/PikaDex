//
//  Pokedex.swift
//  Pokedex
//
//  Created by Daniel Byon on 9/14/22.
//  Copyright © 2022 Daniel Byon. All rights reserved.
//

import Foundation

public enum Pokedex: String, Codable, Equatable {
    case national
    case kanto
    case johto
    case hoenn
    case sinnoh
    case newJohto
    case unova
    case newUnova
    case centralKalos
    case coastalKalos
    case mountainKalos
    case newHoenn
    case alola
    case melemele
    case akala
    case ulaula
    case poni
    case ultraAlola
    case ultraMelemele
    case ultraAkala
    case ultraUlaula
    case ultraPoni
    case letsGoKanto
    case galar
    case isleOfArmor
    case crownTundra
    case hisui
    case paldea

    public var title: String {
        switch self {
        case .national:
            return "National"
        case .kanto, .letsGoKanto:
            return "Kanto"
        case .johto, .newJohto:
            return "Johto"
        case .hoenn, .newHoenn:
            return "Hoenn"
        case .sinnoh:
            return "Sinnoh"
        case .unova, .newUnova:
            return "Unova"
        case .centralKalos:
            return "Central Kalos"
        case .coastalKalos:
            return "Coastal Kalos"
        case .mountainKalos:
            return "Mountain Kalos"
        case .alola, .ultraAlola:
            return "Alola"
        case .melemele, .ultraMelemele:
            return "Melemele"
        case .akala, .ultraAkala:
            return "Akala"
        case .ulaula, .ultraUlaula:
            return "Ula'ula"
        case .poni, .ultraPoni:
            return "Poni"
        case .galar:
            return "Galar"
        case .isleOfArmor:
            return "Isle of Armor"
        case .crownTundra:
            return "The Crown Tundra"
        case .hisui:
            return "Hisui"
        case .paldea:
            return "Paldea"
        }
    }
}
