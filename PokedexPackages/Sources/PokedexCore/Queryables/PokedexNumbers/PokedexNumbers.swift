//
//  PokedexNumbers.swift
//  
//
//  Created by Daniel Byon on 9/19/22.
//

import Foundation

public struct PokedexNumbers {

    public let national: Int
    public let kanto: Int?
    public let johto: Int?
    public let hoenn: Int?
    public let sinnoh: Int?
    public let newJohto: Int?
    public let unova: Int?
    public let newUnova: Int?
    public let centralKalos: Int?
    public let coastalKalos: Int?
    public let mountainKalos: Int?
    public let newHoenn: Int?
    public let alola: Int?
    public let melemele: Int?
    public let akala: Int?
    public let ulaula: Int?
    public let poni: Int?
    public let ultraAlola: Int?
    public let ultraMelemele: Int?
    public let ultraAkala: Int?
    public let ultraUlaula: Int?
    public let ultraPoni: Int?
    public let letsGoKanto: Int?
    public let galar: Int?
    public let isleOfArmor: Int?
    public let crownTundra: Int?
    public let hisui: Int?

    public init(
        national: Int,
        kanto: Int? = nil,
        johto: Int? = nil,
        hoenn: Int? = nil,
        sinnoh: Int? = nil,
        newJohto: Int? = nil,
        unova: Int? = nil,
        newUnova: Int? = nil,
        centralKalos: Int? = nil,
        coastalKalos: Int? = nil,
        mountainKalos: Int? = nil,
        newHoenn: Int? = nil,
        alola: Int? = nil,
        melemele: Int? = nil,
        akala: Int? = nil,
        ulaula: Int? = nil,
        poni: Int? = nil,
        ultraAlola: Int? = nil,
        ultraMelemele: Int? = nil,
        ultraAkala: Int? = nil,
        ultraUlaula: Int? = nil,
        ultraPoni: Int? = nil,
        letsGoKanto: Int? = nil,
        galar: Int? = nil,
        isleOfArmor: Int? = nil,
        crownTundra: Int? = nil,
        hisui: Int? = nil
    ) {
        self.national = national
        self.kanto = kanto
        self.johto = johto
        self.hoenn = hoenn
        self.sinnoh = sinnoh
        self.newJohto = newJohto
        self.unova = unova
        self.newUnova = newUnova
        self.centralKalos = centralKalos
        self.coastalKalos = coastalKalos
        self.mountainKalos = mountainKalos
        self.newHoenn = newHoenn
        self.alola = alola
        self.melemele = melemele
        self.akala = akala
        self.ulaula = ulaula
        self.poni = poni
        self.ultraAlola = ultraAlola
        self.ultraMelemele = ultraMelemele
        self.ultraAkala = ultraAkala
        self.ultraUlaula = ultraUlaula
        self.ultraPoni = ultraPoni
        self.letsGoKanto = letsGoKanto
        self.galar = galar
        self.isleOfArmor = isleOfArmor
        self.crownTundra = crownTundra
        self.hisui = hisui
    }

    public init(pokedexNumbers: StoredPokedexNumbers) {
        self.national = pokedexNumbers.national
        self.kanto = pokedexNumbers.kanto
        self.johto = pokedexNumbers.johto
        self.hoenn = pokedexNumbers.hoenn
        self.sinnoh = pokedexNumbers.sinnoh
        self.newJohto = pokedexNumbers.newJohto
        self.unova = pokedexNumbers.unova
        self.newUnova = pokedexNumbers.newUnova
        self.centralKalos = pokedexNumbers.centralKalos
        self.coastalKalos = pokedexNumbers.coastalKalos
        self.mountainKalos = pokedexNumbers.mountainKalos
        self.newHoenn = pokedexNumbers.newHoenn
        self.alola = pokedexNumbers.alola
        self.melemele = pokedexNumbers.melemele
        self.akala = pokedexNumbers.akala
        self.ulaula = pokedexNumbers.ulaula
        self.poni = pokedexNumbers.poni
        self.ultraAlola = pokedexNumbers.ultraAlola
        self.ultraMelemele = pokedexNumbers.ultraMelemele
        self.ultraAkala = pokedexNumbers.ultraAkala
        self.ultraUlaula = pokedexNumbers.ultraUlaula
        self.ultraPoni = pokedexNumbers.ultraPoni
        self.letsGoKanto = pokedexNumbers.letsGoKanto
        self.galar = pokedexNumbers.galar
        self.isleOfArmor = pokedexNumbers.isleOfArmor
        self.crownTundra = pokedexNumbers.crownTundra
        self.hisui = pokedexNumbers.hisui
    }

}

extension PokedexNumbers: Codable { }

extension PokedexNumbers: Hashable { }

extension PokedexNumbers {

    subscript(pokedex: Pokedex) -> Int {
        number(for: pokedex)
    }

    public func number(for pokedex: Pokedex) -> Int {
        switch pokedex {
        case .national: return national
        case .kanto: return kanto ?? 0
        case .johto: return johto ?? 0
        case .hoenn: return hoenn ?? 0
        case .sinnoh: return sinnoh ?? 0
        case .newJohto: return newJohto ?? 0
        case .unova: return unova ?? 0
        case .newUnova: return newUnova ?? 0
        case .centralKalos: return centralKalos ?? 0
        case .coastalKalos: return coastalKalos ?? 0
        case .mountainKalos: return mountainKalos ?? 0
        case .newHoenn: return newHoenn ?? 0
        case .alola: return alola ?? 0
        case .melemele: return melemele ?? 0
        case .akala: return akala ?? 0
        case .ulaula: return ulaula ?? 0
        case .poni: return poni ?? 0
        case .ultraAlola: return ultraAlola ?? 0
        case .ultraMelemele: return ultraMelemele ?? 0
        case .ultraAkala: return ultraAkala ?? 0
        case .ultraUlaula: return ultraUlaula ?? 0
        case .ultraPoni: return ultraPoni ?? 0
        case .letsGoKanto: return letsGoKanto ?? 0
        case .galar: return galar ?? 0
        case .isleOfArmor: return isleOfArmor ?? 0
        case .crownTundra: return crownTundra ?? 0
        case .hisui: return hisui ?? 0
        }
    }

    public func formattedNumber(for pokedex: Pokedex) -> String {
        let number = NSNumber(value: number(for: pokedex))
        return NumberFormatter.threeDigit.string(from: number)!
    }

}
