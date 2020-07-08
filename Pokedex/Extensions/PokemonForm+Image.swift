//
//  PokemonForm+Image.swift
//  Pokedex
//
//  Created by Daniel Byon on 1/23/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

extension PokemonForm {

    var spriteName: String { menuSpriteResolvedName() }

    var imageName: String { resolvedName(withSuffix: "-image") }

    private var threeDigitPrefix: String { NumberFormatter.threeDigit.string(from: NSNumber(integerLiteral: index))! }

    private func resolvedName(withSuffix suffix: String) -> String {
        var retVal = threeDigitPrefix
        if name != pokemon.name {
            let sanitizedName = name.replacingOccurrences(of: " ", with: "-")
            retVal += "-\(sanitizedName)"
        }
        retVal += suffix
        return retVal
    }

    private func menuSpriteResolvedName() -> String {
        var retVal = threeDigitPrefix
        if name != pokemon.name {
            let sanitizedName = name.replacingOccurrences(of: " ", with: "-")
            retVal += "-\(sanitizedName)"
        }
        retVal += "-menusprite"
        return retVal
    }

}
