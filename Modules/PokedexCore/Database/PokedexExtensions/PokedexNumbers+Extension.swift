//
//  StoredPokedexNumbers+Extension.swift
//  Database
//
//  Created by Daniel Byon on 12/18/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Properties
public extension StoredPokedexNumbers {

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
        case .diamond, .pearl, .platinum, .brilliantDiamond, .shiningPearl:
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
        case .legendsArceus:
            retVal.append(("Hisui", hisui ?? -1))
        case .scarlet, .violet:
            retVal.append(("Paldea", paldea ?? -1))
        case .national:
            retVal.append(("Kanto", kanto ?? -1))
            retVal.append(("Johto", johto ?? -1))
            retVal.append(("Hoenn", hoenn ?? -1))
            retVal.append(("Sinnoh", sinnoh ?? -1))
            retVal.append(("Unova", unova ?? -1))
            retVal.append(("New Unova", newUnova ?? -1))
            retVal.append(("Central Kalos", centralKalos ?? -1))
            retVal.append(("Coastal Kalos", coastalKalos ?? -1))
            retVal.append(("Mountain Kalos", mountainKalos ?? -1))
            retVal.append(("Alola", alola ?? -1))
            retVal.append(("Melemele", melemele ?? -1))
            retVal.append(("Akala", akala ?? -1))
            retVal.append(("Ula'ula", ulaula ?? -1))
            retVal.append(("Poni", poni ?? -1))
            retVal.append(("Alola (USUM)", ultraAlola ?? -1))
            retVal.append(("Melemele (USUM)", ultraMelemele ?? -1))
            retVal.append(("Akala (USUM)", ultraAkala ?? -1))
            retVal.append(("Ula'ula (USUM)", ultraUlaula ?? -1))
            retVal.append(("Poni (USUM)", ultraPoni ?? -1))
            retVal.append(("Galar", galar ?? -1))
            retVal.append(("Isle of Armor", isleOfArmor ?? -1))
            retVal.append(("Crown Tundra", crownTundra ?? -1))
            retVal.append(("Hisui", hisui ?? -1))
        }

        retVal.removeAll { $0.1 == -1 }
        return retVal
    }

}

// MARK: - Values
public extension StoredPokedexNumbers {

    var akala: Int? {
        get { (value(forKeyPath: #keyPath(StoredPokedexNumbers.z_akala)) as? Int16)?.toInt() }
        set { z_akala = newValue?.toInt16() ?? 0 }
    }
    var alola: Int? {
        get { (value(forKeyPath: #keyPath(StoredPokedexNumbers.z_alola)) as? Int16)?.toInt() }
        set { z_alola = newValue?.toInt16() ?? 0 }
    }
    var centralKalos: Int? {
        get { (value(forKeyPath: #keyPath(StoredPokedexNumbers.z_centralKalos)) as? Int16)?.toInt() }
        set { z_centralKalos = newValue?.toInt16() ?? 0 }
    }
    var coastalKalos: Int? {
        get { (value(forKeyPath: #keyPath(StoredPokedexNumbers.z_coastalKalos)) as? Int16)?.toInt() }
        set { z_coastalKalos = newValue?.toInt16() ?? 0 }
    }
    var crownTundra: Int? {
        get { (value(forKeyPath: #keyPath(StoredPokedexNumbers.z_crownTundra)) as? Int16)?.toInt() }
        set { z_crownTundra = newValue?.toInt16() ?? 0 }
    }
    var galar: Int? {
        get { (value(forKeyPath: #keyPath(StoredPokedexNumbers.z_galar)) as? Int16)?.toInt() }
        set { z_galar = newValue?.toInt16() ?? 0 }
    }
    var hisui: Int? {
        get { (value(forKeyPath: #keyPath(StoredPokedexNumbers.z_hisui)) as? Int16)?.toInt() }
        set { z_hisui = newValue?.toInt16() ?? 0 }
    }
    var hoenn: Int? {
        get { (value(forKeyPath: #keyPath(StoredPokedexNumbers.z_hoenn)) as? Int16)?.toInt() }
        set { z_hoenn = newValue?.toInt16() ?? 0 }
    }
    var isleOfArmor: Int? {
        get { (value(forKeyPath: #keyPath(StoredPokedexNumbers.z_isleOfArmor)) as? Int16)?.toInt() }
        set { z_isleOfArmor = newValue?.toInt16() ?? 0 }
    }
    var johto: Int? {
        get { (value(forKeyPath: #keyPath(StoredPokedexNumbers.z_johto)) as? Int16)?.toInt() }
        set { z_johto = newValue?.toInt16() ?? 0 }
    }
    var kanto: Int? {
        get { (value(forKeyPath: #keyPath(StoredPokedexNumbers.z_kanto)) as? Int16)?.toInt() }
        set { z_kanto = newValue?.toInt16() ?? 0 }
    }
    var letsGoKanto: Int? {
        get { (value(forKeyPath: #keyPath(StoredPokedexNumbers.z_letsGoKanto)) as? Int16)?.toInt() }
        set { z_letsGoKanto = newValue?.toInt16() ?? 0 }
    }
    var melemele: Int? {
        get { (value(forKeyPath: #keyPath(StoredPokedexNumbers.z_melemele)) as? Int16)?.toInt() }
        set { z_melemele = newValue?.toInt16() ?? 0 }
    }
    var mountainKalos: Int? {
        get { (value(forKeyPath: #keyPath(StoredPokedexNumbers.z_mountainKalos)) as? Int16)?.toInt() }
        set { z_mountainKalos = newValue?.toInt16() ?? 0 }
    }
    var national: Int {
        get { (value(forKeyPath: #keyPath(StoredPokedexNumbers.z_national)) as? Int16)!.toInt() }
        set { z_national = newValue.toInt16() }
    }
    var newHoenn: Int? {
        get { (value(forKeyPath: #keyPath(StoredPokedexNumbers.z_newHoenn)) as? Int16)?.toInt() }
        set { z_newHoenn = newValue?.toInt16() ?? 0 }
    }
    var newJohto: Int? {
        get { (value(forKeyPath: #keyPath(StoredPokedexNumbers.z_newJohto)) as? Int16)?.toInt() }
        set { z_newJohto = newValue?.toInt16() ?? 0 }
    }
    var newUnova: Int? {
        get { (value(forKeyPath: #keyPath(StoredPokedexNumbers.z_newUnova)) as? Int16)?.toInt() }
        set { z_newUnova = newValue?.toInt16() ?? 0 }
    }
    var ultraAkala: Int? {
        get { (value(forKeyPath: #keyPath(StoredPokedexNumbers.z_ultraAkala)) as? Int16)?.toInt() }
        set { z_ultraAkala = newValue?.toInt16() ?? 0 }
    }
    var paldea: Int? {
        get { (value(forKeyPath: #keyPath(StoredPokedexNumbers.z_paldea)) as? Int16)?.toInt() }
        set { z_paldea = newValue?.toInt16() ?? 0 }
    }
    var poni: Int? {
        get { (value(forKeyPath: #keyPath(StoredPokedexNumbers.z_poni)) as? Int16)?.toInt() }
        set { z_poni = newValue?.toInt16() ?? 0 }
    }
    var sinnoh: Int? {
        get { (value(forKeyPath: #keyPath(StoredPokedexNumbers.z_sinnoh)) as? Int16)?.toInt() }
        set { z_sinnoh = newValue?.toInt16() ?? 0 }
    }
    var ulaula: Int? {
        get { (value(forKeyPath: #keyPath(StoredPokedexNumbers.z_ulaula)) as? Int16)?.toInt() }
        set { z_ulaula = newValue?.toInt16() ?? 0 }
    }
    var ultraAlola: Int? {
        get { (value(forKeyPath: #keyPath(StoredPokedexNumbers.z_ultraAlola)) as? Int16)?.toInt() }
        set { z_ultraAlola = newValue?.toInt16() ?? 0 }
    }
    var ultraMelemele: Int? {
        get { (value(forKeyPath: #keyPath(StoredPokedexNumbers.z_ultraMelemele)) as? Int16)?.toInt() }
        set { z_ultraMelemele = newValue?.toInt16() ?? 0 }
    }
    var ultraPoni: Int? {
        get { (value(forKeyPath: #keyPath(StoredPokedexNumbers.z_ultraPoni)) as? Int16)?.toInt() }
        set { z_ultraPoni = newValue?.toInt16() ?? 0 }
    }
    var ultraUlaula: Int? {
        get { (value(forKeyPath: #keyPath(StoredPokedexNumbers.z_ultraUlaula)) as? Int16)?.toInt() }
        set { z_ultraUlaula = newValue?.toInt16() ?? 0 }
    }
    var unova: Int? {
        get { (value(forKeyPath: #keyPath(StoredPokedexNumbers.z_unova)) as? Int16)?.toInt() }
        set { z_unova = newValue?.toInt16() ?? 0 }
    }

    var pokemon: StoredPokemon {
        get { z_pokemon! }
        set { z_pokemon = newValue }
    }

}
