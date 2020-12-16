//
//  PokemonForm+Image.swift
//  Pokedex
//
//  Created by Daniel Byon on 1/23/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

extension PokemonForm {

    var spriteName: String { PokemonImageNameFormatter.menuSpriteName(forPokemonName: pokemon.name, formName: name, index: index) }

    var imageName: String { PokemonImageNameFormatter.imageName(forPokemonName: pokemon.name, formName: name, index: index) }

}
