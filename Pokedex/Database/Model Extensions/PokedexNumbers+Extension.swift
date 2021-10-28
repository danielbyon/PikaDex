//
//  PokedexNumbers+Extension.swift
//  Database
//
//  Created by Daniel Byon on 12/18/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Properties
public extension PokedexNumbers {

    func all() -> [(String, Int)] {
        var retVal: [(String, Int)] = []
        retVal.append(("National", national))
        switch pokemon.game {
        case .red, .blue, .yellow, .fireRed, .leafGreen:
            retVal.append(("Kanto", kanto ?? -1))
        case .gold, .silver, .crystal:
            retVal.append(("Johto", johto ?? -1))
        case .ruby, .sapphire, .emerald:
            retVal.append(("Hoenn", hoenn ?? -1))
        case .diamond, .pearl, .platinum:
            retVal.append(("Sinnoh", sinnoh ?? -1))
        case .heartGold, .soulSilver:
            retVal.append(("Johto", newJohto ?? -1))
        case .black, .white:
            retVal.append(("Unova", unova ?? -1))
        case .black2, .white2:
            retVal.append(("Unova", newUnova ?? -1))
        case .x, .y:
            retVal.append(("Central Kalos", centralKalos ?? -1))
            retVal.append(("Coastal Kalos", coastalKalos ?? -1))
            retVal.append(("Mountain Kalos", mountainKalos ?? -1))
        case .omegaRuby, .alphaSapphire:
            retVal.append(("Hoenn", newHoenn ?? -1))
        case .sun, .moon:
            retVal.append(("Alola", alola ?? -1))
            retVal.append(("Melemele", melemele ?? -1))
            retVal.append(("Akala", akala ?? -1))
            retVal.append(("Ula'ula", ulaula ?? -1))
            retVal.append(("Poni", poni ?? -1))
        case .ultraSun, .ultraMoon:
            retVal.append(("Alola", ultraAlola ?? -1))
            retVal.append(("Melemele", ultraMelemele ?? -1))
            retVal.append(("Akala", ultraAkala ?? -1))
            retVal.append(("Ula'ula", ultraUlaula ?? -1))
            retVal.append(("Poni", ultraPoni ?? -1))
        case .letsGoPikachu, .letsGoEevee:
            retVal.append(("Kanto", letsGoKanto ?? -1))
        case .sword, .shield:
            retVal.append(("Galar", galar ?? -1))
            retVal.append(("Isle of Armor", isleOfArmor ?? -1))
            retVal.append(("Crown Tundra", crownTundra ?? -1))
        case .national:
            break // national is always added
        }

        retVal.removeAll { $0.1 == -1 }
        return retVal
    }

}

// MARK: - Values
public extension PokedexNumbers {

    var akala: Int? {
        get { (value(forKeyPath: #keyPath(PokedexNumbers.z_akala)) as? Int64)?.toInt() }
        set { z_akala = newValue?.toInt64() ?? 0 }
    }
    var alola: Int? {
        get { (value(forKeyPath: #keyPath(PokedexNumbers.z_alola)) as? Int64)?.toInt() }
        set { z_alola = newValue?.toInt64() ?? 0 }
    }
    var centralKalos: Int? {
        get { (value(forKeyPath: #keyPath(PokedexNumbers.z_centralKalos)) as? Int64)?.toInt() }
        set { z_centralKalos = newValue?.toInt64() ?? 0 }
    }
    var coastalKalos: Int? {
        get { (value(forKeyPath: #keyPath(PokedexNumbers.z_coastalKalos)) as? Int64)?.toInt() }
        set { z_coastalKalos = newValue?.toInt64() ?? 0 }
    }
    var crownTundra: Int? {
        get { (value(forKeyPath: #keyPath(PokedexNumbers.z_crownTundra)) as? Int64)?.toInt() }
        set { z_crownTundra = newValue?.toInt64() ?? 0 }
    }
    var galar: Int? {
        get { (value(forKeyPath: #keyPath(PokedexNumbers.z_galar)) as? Int64)?.toInt() }
        set { z_galar = newValue?.toInt64() ?? 0 }
    }
    var hoenn: Int? {
        get { (value(forKeyPath: #keyPath(PokedexNumbers.z_hoenn)) as? Int64)?.toInt() }
        set { z_hoenn = newValue?.toInt64() ?? 0 }
    }
    var isleOfArmor: Int? {
        get { (value(forKeyPath: #keyPath(PokedexNumbers.z_isleOfArmor)) as? Int64)?.toInt() }
        set { z_isleOfArmor = newValue?.toInt64() ?? 0 }
    }
    var johto: Int? {
        get { (value(forKeyPath: #keyPath(PokedexNumbers.z_johto)) as? Int64)?.toInt() }
        set { z_johto = newValue?.toInt64() ?? 0 }
    }
    var kanto: Int? {
        get { (value(forKeyPath: #keyPath(PokedexNumbers.z_kanto)) as? Int64)?.toInt() }
        set { z_kanto = newValue?.toInt64() ?? 0 }
    }
    var letsGoKanto: Int? {
        get { (value(forKeyPath: #keyPath(PokedexNumbers.z_letsGoKanto)) as? Int64)?.toInt() }
        set { z_letsGoKanto = newValue?.toInt64() ?? 0 }
    }
    var melemele: Int? {
        get { (value(forKeyPath: #keyPath(PokedexNumbers.z_melemele)) as? Int64)?.toInt() }
        set { z_melemele = newValue?.toInt64() ?? 0 }
    }
    var mountainKalos: Int? {
        get { (value(forKeyPath: #keyPath(PokedexNumbers.z_mountainKalos)) as? Int64)?.toInt() }
        set { z_mountainKalos = newValue?.toInt64() ?? 0 }
    }
    var national: Int {
        get { (value(forKeyPath: #keyPath(PokedexNumbers.z_national)) as? Int64)!.toInt() }
        set { z_national = newValue.toInt64() }
    }
    var newHoenn: Int? {
        get { (value(forKeyPath: #keyPath(PokedexNumbers.z_newHoenn)) as? Int64)?.toInt() }
        set { z_newHoenn = newValue?.toInt64() ?? 0 }
    }
    var newJohto: Int? {
        get { (value(forKeyPath: #keyPath(PokedexNumbers.z_newJohto)) as? Int64)?.toInt() }
        set { z_newJohto = newValue?.toInt64() ?? 0 }
    }
    var newUnova: Int? {
        get { (value(forKeyPath: #keyPath(PokedexNumbers.z_newUnova)) as? Int64)?.toInt() }
        set { z_newUnova = newValue?.toInt64() ?? 0 }
    }
    var ultraAkala: Int? {
        get { (value(forKeyPath: #keyPath(PokedexNumbers.z_ultraAkala)) as? Int64)?.toInt() }
        set { z_ultraAkala = newValue?.toInt64() ?? 0 }
    }
    var poni: Int? {
        get { (value(forKeyPath: #keyPath(PokedexNumbers.z_poni)) as? Int64)?.toInt() }
        set { z_poni = newValue?.toInt64() ?? 0 }
    }
    var sinnoh: Int? {
        get { (value(forKeyPath: #keyPath(PokedexNumbers.z_sinnoh)) as? Int64)?.toInt() }
        set { z_sinnoh = newValue?.toInt64() ?? 0 }
    }
    var ulaula: Int? {
        get { (value(forKeyPath: #keyPath(PokedexNumbers.z_ulaula)) as? Int64)?.toInt() }
        set { z_ulaula = newValue?.toInt64() ?? 0 }
    }
    var ultraAlola: Int? {
        get { (value(forKeyPath: #keyPath(PokedexNumbers.z_ultraAlola)) as? Int64)?.toInt() }
        set { z_ultraAlola = newValue?.toInt64() ?? 0 }
    }
    var ultraMelemele: Int? {
        get { (value(forKeyPath: #keyPath(PokedexNumbers.z_ultraMelemele)) as? Int64)?.toInt() }
        set { z_ultraMelemele = newValue?.toInt64() ?? 0 }
    }
    var ultraPoni: Int? {
        get { (value(forKeyPath: #keyPath(PokedexNumbers.z_ultraPoni)) as? Int64)?.toInt() }
        set { z_ultraPoni = newValue?.toInt64() ?? 0 }
    }
    var ultraUlaula: Int? {
        get { (value(forKeyPath: #keyPath(PokedexNumbers.z_ultraUlaula)) as? Int64)?.toInt() }
        set { z_ultraUlaula = newValue?.toInt64() ?? 0 }
    }
    var unova: Int? {
        get { (value(forKeyPath: #keyPath(PokedexNumbers.z_unova)) as? Int64)?.toInt() }
        set { z_unova = newValue?.toInt64() ?? 0 }
    }

    var pokemon: StoredPokemon {
        get { z_pokemon! }
        set { z_pokemon = newValue }
    }

}
