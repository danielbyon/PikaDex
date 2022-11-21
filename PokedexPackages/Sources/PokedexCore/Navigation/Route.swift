//
//  Route.swift
//  Pokedex
//
//  Created by Daniel Byon on 9/9/22.
//  Copyright © 2022 Daniel Byon. All rights reserved.
//

import Foundation

public enum Route: Codable, Hashable {
    case battleAssistant(BattleAssistant)
    case content(Content)
    case tab(Tab)
    case url(URL)

    public enum BattleAssistant: Codable, Hashable {
        case selectPokemon(Game)
    }

    public enum Content: Codable, Hashable {
        case ability(_ ability: Ability, game: Game, pokedex: Pokedex)
        case abilityPokemonForm(_ pokemonForm: AbilityPokemonForm, pokedex: Pokedex)
        case evolutionPokemonForm(_ pokemonForm: Evolution.PokemonForm, pokedex: Pokedex)
        case item(_ item: Item)
        case learnset(_ pokemonForm: PokemonDetailForm, game: Game, learnsetType: LearnsetType)
        case learnsetPokemonForm(_ pokemonForm: LearnsetPokemonForm)
        case location(_ location: Location)
        case move(_ move: Move)
        case pokemon(_ pokemon: Pokemon, pokedex: Pokedex)
        case pokemonDetailForm(_ pokemonDetailForm: PokemonDetailForm, pokedex: Pokedex)
        case pokemonLocations(_ pokemonDetailForm: PokemonDetailForm)
        case type(_ type: PokemonType, game: Game)
    }

}
