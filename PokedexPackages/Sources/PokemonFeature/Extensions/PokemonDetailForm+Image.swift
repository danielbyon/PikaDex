//
//  PokemonDetailForm+Image.swift
//  
//
//  Created by Daniel Byon on 9/22/22.
//

import PokedexUI

extension PokemonDetailForm {

    public var spriteName: String { PokemonImageNameFormatter.menuSpriteName(forPokemonName: pokemonName, formName: name, index: index) }

    public var imageName: String { PokemonImageNameFormatter.imageName(forPokemonName: pokemonName, formName: name, index: index) }

}
