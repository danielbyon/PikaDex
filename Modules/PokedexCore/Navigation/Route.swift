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
        case type(_ type: PokemonType, game: Game)
    }

}

extension Route.Content: Codable {

    private enum CodingKeys: String, CodingKey {
        case discriminator
        case ability
        case abilityPokemonForm
        case evolutionPokemonForm
        case game
        case item
        case learnsetPokemonForm
        case learnsetType
        case location
        case move
        case pokedex
        case pokemon
        case pokemonDetailForm
        case type
    }

    private enum Discriminator: String, Codable {
        case ability
        case abilityPokemonForm
        case evolutionPokemonForm
        case item
        case learnset
        case learnsetPokemonForm
        case location
        case move
        case pokemon
        case pokemonDetailForm
        case pokemonLocations
        case type
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let discriminator = try container.decode(Discriminator.self, forKey: .discriminator)
        switch discriminator {
        case .ability:
            let ability = try container.decode(Ability.self, forKey: .ability)
            let game = try container.decode(Game.self, forKey: .game)
            let pokedex = try container.decode(Pokedex.self, forKey: .pokedex)
            self = .ability(ability, game: game, pokedex: pokedex)
        case .abilityPokemonForm:
            let pokemonForm = try container.decode(AbilityPokemonForm.self, forKey: .abilityPokemonForm)
            let pokedex = try container.decode(Pokedex.self, forKey: .pokedex)
            self = .abilityPokemonForm(pokemonForm, pokedex: pokedex)
        case .evolutionPokemonForm:
            let pokemonForm = try container.decode(Evolution.PokemonForm.self, forKey: .evolutionPokemonForm)
            let pokedex = try container.decode(Pokedex.self, forKey: .pokedex)
            self = .evolutionPokemonForm(pokemonForm, pokedex: pokedex)
        case .item:
            let item = try container.decode(Item.self, forKey: .item)
            self = .item(item)
        case .learnset:
            let pokemonForm = try container.decode(PokemonDetailForm.self, forKey: .pokemonDetailForm)
            let game = try container.decode(Game.self, forKey: .game)
            let learnsetType = try container.decode(LearnsetType.self, forKey: .learnsetType)
            self = .learnset(pokemonForm, game: game, learnsetType: learnsetType)
        case .learnsetPokemonForm:
            let pokemonForm = try container.decode(LearnsetPokemonForm.self, forKey: .learnsetPokemonForm)
            self = .learnsetPokemonForm(pokemonForm)
        case .location:
            let location = try container.decode(Location.self, forKey: .location)
            self = .location(location)
        case .move:
            let move = try container.decode(Move.self, forKey: .move)
            self = .move(move)
        case .pokemon:
            let pokemon = try container.decode(Pokemon.self, forKey: .pokemon)
            let pokedex = try container.decode(Pokedex.self, forKey: .pokedex)
            self = .pokemon(pokemon, pokedex: pokedex, previousPokemonProvider: nil, nextPokemonProvider: nil)
        case .pokemonDetailForm:
            let pokemonDetailForm = try container.decode(PokemonDetailForm.self, forKey: .pokemonDetailForm)
            let pokedex = try container.decode(Pokedex.self, forKey: .pokedex)
            self = .pokemonDetailForm(pokemonDetailForm, pokedex: pokedex)
        case .pokemonLocations:
            let pokemonDetailForm = try container.decode(PokemonDetailForm.self, forKey: .pokemonDetailForm)
            self = .pokemonLocations(pokemonDetailForm)
        case .type:
            let type = try container.decode(PokemonType.self, forKey: .type)
            let game = try container.decode(Game.self, forKey: .game)
            self = .type(type, game: game)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .ability(ability, game, pokedex):
            try container.encode(Discriminator.ability, forKey: .discriminator)
            try container.encode(ability, forKey: .ability)
            try container.encode(game, forKey: .game)
            try container.encode(pokedex, forKey: .pokedex)
        case let .abilityPokemonForm(pokemonForm, pokedex):
            try container.encode(Discriminator.abilityPokemonForm, forKey: .discriminator)
            try container.encode(pokemonForm, forKey: .abilityPokemonForm)
            try container.encode(pokedex, forKey: .pokedex)
        case let .evolutionPokemonForm(pokemonForm, pokedex):
            try container.encode(Discriminator.evolutionPokemonForm, forKey: .discriminator)
            try container.encode(pokemonForm, forKey: .evolutionPokemonForm)
            try container.encode(pokedex, forKey: .pokedex)
        case let .item(item):
            try container.encode(Discriminator.item, forKey: .discriminator)
            try container.encode(item, forKey: .item)
        case let .learnset(pokemonForm, game, learnsetType):
            try container.encode(Discriminator.learnset, forKey: .discriminator)
            try container.encode(pokemonForm, forKey: .learnsetPokemonForm)
            try container.encode(game, forKey: .game)
            try container.encode(learnsetType, forKey: .learnsetType)
        case let .learnsetPokemonForm(pokemonForm):
            try container.encode(Discriminator.learnsetPokemonForm, forKey: .discriminator)
            try container.encode(pokemonForm, forKey: .learnsetPokemonForm)
        case let .location(location):
            try container.encode(Discriminator.location, forKey: .discriminator)
            try container.encode(location, forKey: .location)
        case let .move(move):
            try container.encode(Discriminator.move, forKey: .discriminator)
            try container.encode(move, forKey: .move)
        case let .pokemon(pokemon, pokedex, _, _):
            try container.encode(Discriminator.pokemon, forKey: .discriminator)
            try container.encode(pokemon, forKey: .pokemon)
            try container.encode(pokedex, forKey: .pokedex)
        case let .pokemonDetailForm(pokemonDetailForm, pokedex):
            try container.encode(Discriminator.pokemonDetailForm, forKey: .discriminator)
            try container.encode(pokemonDetailForm, forKey: .pokemonDetailForm)
            try container.encode(pokedex, forKey: .pokedex)
        case let .pokemonLocations(pokemonDetailForm):
            try container.encode(Discriminator.pokemonLocations, forKey: .discriminator)
            try container.encode(pokemonDetailForm, forKey: .pokemonDetailForm)
        case let .type(type, game):
            try container.encode(Discriminator.type, forKey: .discriminator)
            try container.encode(type, forKey: .type)
            try container.encode(game, forKey: .game)
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
        case let .type(type, game):
            hasher.combine("type")
            hasher.combine(type)
            hasher.combine(game)
        }
    }

}
