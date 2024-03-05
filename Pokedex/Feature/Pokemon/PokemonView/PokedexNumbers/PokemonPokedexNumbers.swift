//
//  PokemonPokedexNumbers.swift
//  
//
//  Created by Daniel Byon on 10/16/22.
//

import PokedexUI
import SwiftUI

struct PokemonPokedexNumbers: View {

    let pokedexNumbers: PokedexNumbers
    let game: Game

    private var viewModels: [PokedexNumberViewModel] {
        let allNumbers = pokedexNumbers.all(game: game)
        return allNumbers.compactMap { PokedexNumberViewModel(name: $0.0, number: $0.1) }
    }

    var body: some View {
        ForEach(viewModels) { viewModel in
            Value1Cell(text: viewModel.name, detailText: viewModel.number)
        }
    }

}

struct PokemonPokedexNumbers_Previews: PreviewProvider {
    static var previews: some View {
        PokemonPokedexNumbers(
            pokedexNumbers: .init(
                national: 1,
                kanto: 2,
                johto: 3,
                hoenn: 4,
                sinnoh: 5,
                newJohto: 6,
                unova: 7,
                newUnova: 8,
                centralKalos: 9,
                coastalKalos: 10,
                mountainKalos: 11,
                newHoenn: 12,
                alola: 13,
                melemele: 14,
                akala: 15,
                ulaula: 16,
                poni: 17,
                ultraAlola: 18,
                ultraMelemele: 19,
                ultraAkala: 20,
                ultraUlaula: 21,
                ultraPoni: 22,
                letsGoKanto: 23,
                galar: 24,
                isleOfArmor: 25,
                crownTundra: 26,
                hisui: 27,
                kitakami: 28,
                blueberry: 29
            ),
            game: .national
        )
    }
}

private struct PokedexNumberViewModel {
    let name: String
    let number: String

    init?(name: String, number: Int) {
        guard let numberString = NumberFormatter.pokemonIndex.string(from: NSNumber(value: number)) else { return nil }
        self.name = name
        self.number = numberString
    }
}

extension PokedexNumberViewModel: Identifiable {

    var id: String { name }

}

private extension PokedexNumbers {

    func all(game: Game) -> [(String, Int)] {
        var retVal: [(String, Int)] = []
        retVal.append(("National", national))
        switch game {
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
            retVal.append(("Kitakami", kitakami ?? -1))
            retVal.append(("Blueberry", blueberry ?? -1))
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
            retVal.append(("Paldea", paldea ?? -1))
            retVal.append(("Kitakami", kitakami ?? -1))
            retVal.append(("Blueberry", blueberry ?? -1))
        }

        retVal.removeAll { $0.1 == -1 }
        return retVal
    }

}
