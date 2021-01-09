//
//  PokemonImageNameFormatter.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/8/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

enum PokemonImageNameFormatter {

    static func imageName(forPokemonName pokemonName: String, formName: String, index: Int) -> String {
        resolvedName(forPokemonName: pokemonName, formName: formName, index: index, suffix: "-image")
    }

    static func menuSpriteName(forPokemonName pokemonName: String, formName: String, index: Int) -> String {
        resolvedName(forPokemonName: pokemonName, formName: formName, index: index, suffix: "-menusprite")
    }

    private static func resolvedName(forPokemonName pokemonName: String, formName: String, index: Int, suffix: String) -> String {
        var retVal = NumberFormatter.threeDigit.string(from: NSNumber(integerLiteral: index))!
        if formName != pokemonName {
            let sanitizedName = formName.replacingOccurrences(of: " ", with: "-")
            retVal += "-\(sanitizedName)"
        }
        retVal += suffix
        return retVal
    }

}
