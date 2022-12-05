//
//  PokemonBasicInfo.swift
//  
//
//  Created by Daniel Byon on 10/16/22.
//

import PokedexUI
import SwiftUI

struct PokemonBasicInfo: View {

    let pokemon: PokemonDetail
    let pokemonForm: PokemonDetailForm

    @AppStorage(.shouldUseMetersForHeight, store: .appGroup) private var shouldUseMetersForHeight = true
    @AppStorage(.shouldUseKilogramsForWeight, store: .appGroup) private var shouldUseKilogramsForWeight = true

    private var generationIntroducedString: String { pokemon.generationIntroduced.title }
    private var catchRateString: String { "\(pokemon.catchRate)" }
    private var levelingRateString: String { pokemon.levelingRate.title }
    private var baseFriendshipString: String { "\(pokemonForm.baseFriendship)" }
    private var heightString: String {
        let height = shouldUseMetersForHeight ? pokemonForm.heightInMeters : Measurement(value: pokemonForm.heightInMeters, unit: UnitLength.meters).converted(to: .feet).value
        let isPlusHeight = height < 0
        let heightUnit = shouldUseMetersForHeight ? LengthFormatter.Unit.meter : .foot
        var heightString = LengthFormatter.height.string(fromValue: abs(height), unit: heightUnit)
        if isPlusHeight {
            heightString += "+" // Display "<number>+" when height < 0
        }
        return heightString
    }
    private var weightString: String {
        let weight = shouldUseKilogramsForWeight ? pokemonForm.weightInKilograms : Measurement(value: pokemonForm.weightInKilograms, unit: UnitMass.kilograms).converted(to: .pounds).value
        let isIndeterminateWeight = weight < 0
        let weightUnit = shouldUseKilogramsForWeight ? MassFormatter.Unit.kilogram : .pound
        let weightString: String
        if isIndeterminateWeight {
            // Display "???" when weight == -1
            weightString = "???"
        } else {
            weightString = MassFormatter.weight.string(fromValue: weight, unit: weightUnit)
        }
        return weightString
    }
    private var baseExperienceYieldString: String { "\(pokemonForm.baseExperienceYield)" }

    var body: some View {
        Value1Cell(text: "Introduced", detailText: generationIntroducedString)
        Value1Cell(text: "Height", detailText: heightString)
        Value1Cell(text: "Weight", detailText: weightString)
        GenderRatioCell(maleRatio: pokemon.maleRatio)
        EggGroupsCell(eggGroups: pokemon.eggGroups)
        Value1Cell(text: "Catch Rate", detailText: catchRateString)
        Value1Cell(text: "Leveling Rate", detailText: levelingRateString)
        Value1Cell(text: "Base Friendship", detailText: baseFriendshipString)
        Value1Cell(text: "Base XP Yield", detailText: baseExperienceYieldString)
    }

}

struct PokemonBasicInfo_Previews: PreviewProvider {
    static var previews: some View {
        PokemonBasicInfo(pokemon: .charizard, pokemonForm: .charizard)
    }
}
