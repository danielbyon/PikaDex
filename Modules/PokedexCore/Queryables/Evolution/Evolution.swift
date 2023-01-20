//
//  Evolution.swift
//  
//
//  Created by Daniel Byon on 9/21/22.
//

import Foundation

public struct Evolution {

    public let familyName: String
    public let game: Game
    public let method: Method
    public let condition: Condition?
    public let condition2: Condition?
    public let from: PokemonForm
    public let to: PokemonForm

    public struct PokemonForm {

        public let name: String
        public let formName: String
        public let formIndex: Int
        public let color: PokemonColor
        public let spriteName: String
        public let game: Game

        init(pokemonForm: StoredPokemonForm) {
            name = pokemonForm.pokemon.name
            formName = pokemonForm.name
            formIndex = pokemonForm.formIndex
            color = pokemonForm.color
            spriteName = pokemonForm.spriteName
            game = pokemonForm.game
        }

    }

    public enum Method {

        case completeBattlePerformingAction(String)
        case friendship
        case levelUp(Int)
        case levelUpHoldingItem(String, spriteName: String)
        case levelUpInArea(String)
        case levelUpKnowingMove(String)
        case levelUpWithPartyMember(String)
        case levelUpWithStats(String)
        case other(String)
        case trade
        case tradeForPokemon(String)
        case tradeHoldingItem(String, spriteName: String)
        case trainerAction(String)
        case useItem(String, spriteName: String)

        init(_ method: EvolutionMethod) {
            switch method {
            case .completeBattlePerformingAction(let action):
                self = .completeBattlePerformingAction(action)
            case .friendship:
                self = .friendship
            case .levelUp(let level):
                self = .levelUp(level)
            case .levelUpHoldingItem(let item):
                self = .levelUpHoldingItem(item.name, spriteName: item.imageName)
            case .levelUpInArea(let area):
                self = .levelUpInArea(area)
            case .levelUpKnowingMove(let move):
                self = .levelUpKnowingMove(move.name)
            case .levelUpWithPartyMember(let pokemon):
                self = .levelUpWithPartyMember(pokemon.name)
            case .levelUpWithStats(let stats):
                self = .levelUpWithStats(stats)
            case .other(let value):
                self = .other(value)
            case .trade:
                self = .trade
            case .tradeForPokemon(let pokemon):
                self = .tradeForPokemon(pokemon.name)
            case .tradeHoldingItem(let item):
                self = .tradeHoldingItem(item.name, spriteName: item.imageName)
            case .trainerAction(let action):
                self = .trainerAction(action)
            case .useItem(let item):
                self = .useItem(item.name, spriteName: item.imageName)
            }
        }

    }

    public enum Condition {

        case deviceHeldUpsideDown
        case gender(Gender)
        case haveAbility(String)
        case other(String)
        case partyMemberType(PokemonType)
        case region(Region)
        case timeOfDay(TimeOfDay)
        case weather(Weather)

        init?(_ condition: EvolutionCondition?) {
            guard let condition else { return nil }
            switch condition {
            case .deviceHeldUpsideDown:
                self = .deviceHeldUpsideDown
            case .gender(let gender):
                self = .gender(gender)
            case .haveAbility(let ability):
                self = .haveAbility(ability.name)
            case .other(let value):
                self = .other(value)
            case .partyMemberType(let type):
                self = .partyMemberType(type)
            case .region(let region):
                self = .region(region)
            case .timeOfDay(let timeOfDay):
                self = .timeOfDay(timeOfDay)
            case .weather(let weather):
                self = .weather(weather)
            }
        }

    }

    init(_ result: StoredEvolution) {
        familyName = result.familyName
        game = result.game
        method = .init(result.method)
        condition = .init(result.condition)
        condition2 = .init(result.condition2)
        from = .init(pokemonForm: result.from)
        to = .init(pokemonForm: result.to)
    }

}

extension Evolution: Codable { }

extension Evolution: Hashable { }

extension Evolution: Identifiable {

    public var id: String {
        familyName + from.name + from.formName + to.name + to.formName + game.rawValue
    }

}

extension Evolution.Condition: Codable { }

extension Evolution.Condition: Hashable { }

extension Evolution.Method: Codable { }

extension Evolution.Method: Hashable { }

extension Evolution.PokemonForm: Codable { }

extension Evolution.PokemonForm: Hashable { }
