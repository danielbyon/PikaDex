//
//  Game+PokemonFilter.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/24/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

extension Game {

    var nationalFilterBy: Pokemon.Filter.FilterBy { .init(title: "All Pokémon in \(title)", keyPath: #keyPath(Pokemon.z_index)) }

    var filterBys: [Pokemon.Filter.FilterBy] {
        var filters = [nationalFilterBy]
        switch self {
        case .red, .blue, .yellow, .fireRed, .leafGreen:
            filters.append(Pokemon.Filter.FilterBy(title: "Regional (Kanto)", keyPath: #keyPath(Pokemon.z_pokedexNumbers.z_kanto)))
        case .gold, .silver, .crystal:
            filters.append(Pokemon.Filter.FilterBy(title: "Regional (Johto)", keyPath: #keyPath(Pokemon.z_pokedexNumbers.z_johto)))
        case .ruby, .sapphire, .emerald:
            filters.append(Pokemon.Filter.FilterBy(title: "Regional (Hoenn)", keyPath: #keyPath(Pokemon.z_pokedexNumbers.z_hoenn)))
        case .diamond, .pearl, .platinum:
            filters.append(Pokemon.Filter.FilterBy(title: "Regional (Sinnoh)", keyPath: #keyPath(Pokemon.z_pokedexNumbers.z_sinnoh)))
        case .heartGold, .soulSilver:
            filters.append(Pokemon.Filter.FilterBy(title: "Regional (Johto)", keyPath: #keyPath(Pokemon.z_pokedexNumbers.z_newJohto)))
        case .black, .white:
            filters.append(Pokemon.Filter.FilterBy(title: "Regional (Unova)", keyPath: #keyPath(Pokemon.z_pokedexNumbers.z_unova)))
        case .black2, .white2:
            filters.append(Pokemon.Filter.FilterBy(title: "Regional (Unova)", keyPath: #keyPath(Pokemon.z_pokedexNumbers.z_newUnova)))
        case .x, .y:
            filters.append(Pokemon.Filter.FilterBy(title: "Regional (Central Kalos)", keyPath: #keyPath(Pokemon.z_pokedexNumbers.z_centralKalos)))
            filters.append(Pokemon.Filter.FilterBy(title: "Regional (Coastal Kalos)", keyPath: #keyPath(Pokemon.z_pokedexNumbers.z_coastalKalos)))
            filters.append(Pokemon.Filter.FilterBy(title: "Regional (Mountain Kalos)", keyPath: #keyPath(Pokemon.z_pokedexNumbers.z_mountainKalos)))
        case .omegaRuby, .alphaSapphire:
            filters.append(Pokemon.Filter.FilterBy(title: "Regional (Hoenn)", keyPath: #keyPath(Pokemon.z_pokedexNumbers.z_newHoenn)))
        case .sun, .moon:
            filters.append(Pokemon.Filter.FilterBy(title: "Regional (Alola)", keyPath: #keyPath(Pokemon.z_pokedexNumbers.z_alola)))
            filters.append(Pokemon.Filter.FilterBy(title: "Regional (Melemele)", keyPath: #keyPath(Pokemon.z_pokedexNumbers.z_melemele)))
            filters.append(Pokemon.Filter.FilterBy(title: "Regional (Akala)", keyPath: #keyPath(Pokemon.z_pokedexNumbers.z_akala)))
            filters.append(Pokemon.Filter.FilterBy(title: "Regional (Ula'ula)", keyPath: #keyPath(Pokemon.z_pokedexNumbers.z_ulaula)))
            filters.append(Pokemon.Filter.FilterBy(title: "Regional (Poni)", keyPath: #keyPath(Pokemon.z_pokedexNumbers.z_poni)))
        case .ultraSun, .ultraMoon:
            filters.append(Pokemon.Filter.FilterBy(title: "Regional (Alola)", keyPath: #keyPath(Pokemon.z_pokedexNumbers.z_ultraAlola)))
            filters.append(Pokemon.Filter.FilterBy(title: "Regional (Melemele)", keyPath: #keyPath(Pokemon.z_pokedexNumbers.z_ultraMelemele)))
            filters.append(Pokemon.Filter.FilterBy(title: "Regional (Akala)", keyPath: #keyPath(Pokemon.z_pokedexNumbers.z_ultraAkala)))
            filters.append(Pokemon.Filter.FilterBy(title: "Regional (Ula'ula)", keyPath: #keyPath(Pokemon.z_pokedexNumbers.z_ultraUlaula)))
            filters.append(Pokemon.Filter.FilterBy(title: "Regional (Poni)", keyPath: #keyPath(Pokemon.z_pokedexNumbers.z_ultraPoni)))
        case .letsGoPikachu, .letsGoEevee:
            filters.append(Pokemon.Filter.FilterBy(title: "Regional (Kanto)", keyPath: #keyPath(Pokemon.z_pokedexNumbers.z_letsGoKanto)))
        case .sword, .shield:
            filters.append(Pokemon.Filter.FilterBy(title: "Regional (Galar)", keyPath: #keyPath(Pokemon.z_pokedexNumbers.z_galar)))
            filters.append(Pokemon.Filter.FilterBy(title: "Regional (Isle of Armor)", keyPath: #keyPath(Pokemon.z_pokedexNumbers.z_isleOfArmor)))
            filters.append(Pokemon.Filter.FilterBy(title: "Regional (The Crown Tundra)", keyPath: #keyPath(Pokemon.z_pokedexNumbers.z_crownTundra)))
        }
        return filters
    }

}
