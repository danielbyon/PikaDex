//
//  Game+PokemonFilter.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/24/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

extension Game {

    public var nationalFilterBy: StoredPokemon.Filter.FilterBy { .init(title: "All Pokémon in \(title)", keyPath: #keyPath(StoredPokemon.z_index)) }

    public var filterBys: [StoredPokemon.Filter.FilterBy] {
        var filters = [nationalFilterBy]
        switch self {
        case .red, .blue, .yellow, .fireRed, .leafGreen:
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Kanto)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_kanto)))
        case .gold, .silver, .crystal:
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Johto)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_johto)))
        case .ruby, .sapphire, .emerald:
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Hoenn)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_hoenn)))
        case .diamond, .pearl, .platinum, .brilliantDiamond, .shiningPearl:
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Sinnoh)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_sinnoh)))
        case .heartGold, .soulSilver:
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Johto)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_newJohto)))
        case .black, .white:
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Unova)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_unova)))
        case .black2, .white2:
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Unova)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_newUnova)))
        case .x, .y:
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Central Kalos)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_centralKalos)))
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Coastal Kalos)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_coastalKalos)))
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Mountain Kalos)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_mountainKalos)))
        case .omegaRuby, .alphaSapphire:
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Hoenn)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_newHoenn)))
        case .sun, .moon:
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Alola)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_alola)))
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Melemele)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_melemele)))
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Akala)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_akala)))
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Ula'ula)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_ulaula)))
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Poni)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_poni)))
        case .ultraSun, .ultraMoon:
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Alola)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_ultraAlola)))
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Melemele)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_ultraMelemele)))
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Akala)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_ultraAkala)))
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Ula'ula)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_ultraUlaula)))
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Poni)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_ultraPoni)))
        case .letsGoPikachu, .letsGoEevee:
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Kanto)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_letsGoKanto)))
        case .sword, .shield:
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Galar)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_galar)))
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Isle of Armor)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_isleOfArmor)))
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (The Crown Tundra)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_crownTundra)))
        case .legendsArceus:
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Hisui)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_hisui)))
        case .national:
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Kanto)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_kanto)))
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Johto)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_johto)))
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Hoenn)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_hoenn)))
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Sinnoh)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_sinnoh)))
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Unova)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_newUnova)))
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Central Kalos)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_centralKalos)))
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Coastal Kalos)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_coastalKalos)))
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Mountain Kalos)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_mountainKalos)))
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Alola)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_ultraAlola)))
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Melemele)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_ultraMelemele)))
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Akala)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_ultraAkala)))
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Ula'ula)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_ultraUlaula)))
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Poni)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_ultraPoni)))
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Galar)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_galar)))
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Isle of Armor)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_isleOfArmor)))
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (The Crown Tundra)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_crownTundra)))
            filters.append(StoredPokemon.Filter.FilterBy(title: "Regional (Hisui)", keyPath: #keyPath(StoredPokemon.z_pokedexNumbers.z_hisui)))
            break
        }
        return filters
    }

}
