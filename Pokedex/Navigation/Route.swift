//
//  Route.swift
//  Pokedex
//
//  Created by Daniel Byon on 9/9/22.
//  Copyright © 2022 Daniel Byon. All rights reserved.
//

import Foundation

public enum Route: Hashable {

    case battleAssistant(BattleAssistant)
    case content(Content)
    case tab(Tab)
    case url(URL)

    public enum BattleAssistant {
        case selectPokemon(Game, onSelect: (PokemonDetailForm) -> Void)
    }

    public enum Content {
        case ability(_ ability: Ability, game: Game, pokedex: Pokedex)
        case abilityPokemonForm(_ pokemonForm: AbilityPokemonForm, pokedex: Pokedex)
        case evolutionPokemonForm(_ pokemonForm: Evolution.PokemonForm, pokedex: Pokedex)
        case item(_ item: Item)
        case learnset(_ pokemonForm: PokemonDetailForm, game: Game, learnsetType: LearnsetType)
        case learnsetPokemonForm(_ pokemonForm: LearnsetPokemonForm)
        case location(_ location: Location)
        case move(_ move: Move)
        case pokemon(_ pokemon: Pokemon, pokedex: Pokedex, previousPokemonProvider: ((Int) -> Pokemon?)?, nextPokemonProvider: ((Int) -> Pokemon?)?)
        case pokemonDetailForm(_ pokemonDetailForm: PokemonDetailForm, pokedex: Pokedex)
        case pokemonLocations(_ pokemonDetailForm: PokemonDetailForm)
        case team(_ team: TeamViewModel)
        case teamMember(_ member: TeamMemberViewModel)
        case type(_ type: PokemonType, game: Game)
    }

}

extension Route.BattleAssistant: Equatable {

    public static func == (lhs: Route.BattleAssistant, rhs: Route.BattleAssistant) -> Bool {
        switch (lhs, rhs) {
        case let (.selectPokemon(lGame, _), .selectPokemon(rGame, _)):
            return lGame == rGame
        }
    }

}

extension Route.BattleAssistant: Hashable {

    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .selectPokemon(game, _):
            hasher.combine(game)
        }
    }

}

extension Route.Content: Equatable {

    public static func == (lhs: Route.Content, rhs: Route.Content) -> Bool {
        switch (lhs, rhs) {
        case let (.ability(lAbility, lGame, lPokedex), .ability(rAbility, rGame, rPokedex)):
            return lAbility == rAbility
            && lGame == rGame
            && lPokedex == rPokedex
        case let (.abilityPokemonForm(lPokemonForm, lPokedex), .abilityPokemonForm(rPokemonForm, rPokedex)):
            return lPokemonForm == rPokemonForm
            && lPokedex == rPokedex
        case let (.evolutionPokemonForm(lPokemonForm, lPokedex), .evolutionPokemonForm(rPokemonForm, rPokedex)):
            return lPokemonForm == rPokemonForm
            && lPokedex == rPokedex
        case let (.item(lItem), .item(rItem)):
            return lItem == rItem
        case let (.learnset(lPokemonForm, lGame, lLearnsetType), .learnset(rPokemonForm, rGame, rLearnsetType)):
            return lPokemonForm == rPokemonForm
            && lGame == rGame
            && lLearnsetType == rLearnsetType
        case let (.learnsetPokemonForm(lPokemonForm), .learnsetPokemonForm(rPokemonForm)):
            return lPokemonForm == rPokemonForm
        case let (.location(lLocation), .location(rLocation)):
            return lLocation == rLocation
        case let (.move(lMove), .move(rMove)):
            return lMove == rMove
        case let (.pokemon(lPokemon, lPokedex, _, _), .pokemon(rPokemon, rPokedex, _, _)):
            return lPokemon == rPokemon
            && lPokedex == rPokedex
        case let (.pokemonDetailForm(lPokemonDetailForm, lPokedex), .pokemonDetailForm(rPokemonDetailForm, rPokedex)):
            return lPokemonDetailForm == rPokemonDetailForm
            && lPokedex == rPokedex
        case let (.pokemonLocations(lPokemonDetailForm), .pokemonLocations(rPokemonDetailForm)):
            return lPokemonDetailForm == rPokemonDetailForm
        case let (.team(lTeam), .team(rTeam)):
            return lTeam.team == rTeam.team
        case let (.teamMember(lMember), .teamMember(rMember)):
            return lMember.teamMember == rMember.teamMember
        case let (.type(lType, lGame), .type(rType, rGame)):
            return lType == rType
            && lGame == rGame
        default:
            return false
        }
    }

}

extension Route.Content: Hashable {

    public func hash(into hasher: inout Hasher) {
        switch self {
        case let .ability(ability, game, pokedex):
            hasher.combine("ability")
            hasher.combine(ability)
            hasher.combine(game)
            hasher.combine(pokedex)
        case let .abilityPokemonForm(pokemonForm, pokedex):
            hasher.combine("abilityPokemonForm")
            hasher.combine(pokemonForm)
            hasher.combine(pokedex)
        case let .evolutionPokemonForm(pokemonForm, pokedex):
            hasher.combine("evolutionPokemonForm")
            hasher.combine(pokemonForm)
            hasher.combine(pokedex)
        case let .item(item):
            hasher.combine("item")
            hasher.combine(item)
        case let .learnset(pokemonForm, game, learnsetType):
            hasher.combine("learnset")
            hasher.combine(pokemonForm)
            hasher.combine(game)
            hasher.combine(learnsetType)
        case let .learnsetPokemonForm(pokemonForm):
            hasher.combine("learnsetPokemonForm")
            hasher.combine(pokemonForm)
        case let .location(location):
            hasher.combine("location")
            hasher.combine(location)
        case let .move(move):
            hasher.combine("move")
            hasher.combine(move)
        case let .pokemon(pokemon, pokedex, _, _):
            hasher.combine("pokemon")
            hasher.combine(pokemon)
            hasher.combine(pokedex)
        case let .pokemonDetailForm(pokemonDetailForm, pokedex):
            hasher.combine("pokemonDetailForm")
            hasher.combine(pokemonDetailForm)
            hasher.combine(pokedex)
        case let .pokemonLocations(pokemonDetailForm):
            hasher.combine("pokemonLocations")
            hasher.combine(pokemonDetailForm)
        case let .team(team):
            hasher.combine(team.team.internalID)
            hasher.combine(team.team.members.count)
        case let .teamMember(member):
            hasher.combine(member.teamMember.internalID)
        case let .type(type, game):
            hasher.combine("type")
            hasher.combine(type)
            hasher.combine(game)
        }
    }

}
