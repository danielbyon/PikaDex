//
//  PokemonForm.swift
//  
//
//  Created by Daniel Byon on 9/21/22.
//

import CoreData
import Foundation

public struct PokemonDetailForm: Queryable {

    public typealias Filter = PokemonDetailFormFilter

    public let name: String
    public let pokemonName: String
    public let baseExperienceYield: Int
    public let baseFriendship: Int
    public let color: PokemonColor
    public let familyName: String
    public let formIndex: Int
    public let game: Game
    public let heightInMeters: Double
    public let index: Int
    public let pokedexEntry: String
    public let primaryType: PokemonType
    public let secondaryType: PokemonType?
    public let species: String
    public let weightInKilograms: Double
    public let spriteName: String
    public let baseStats: Stats
    public let evolutions: [Evolution]?
    public let evYield: Stats
    public let hiddenAbility: Ability?
    public let primaryAbility: Ability?
    public let secondaryAbility: Ability?
    public let pokedexNumbers: PokedexNumbers

    public var isMainForm: Bool { formIndex == 0 }

    public var hasAbilities: Bool { primaryAbility != nil || secondaryAbility != nil || hiddenAbility != nil }

    public init(result: StoredPokemonForm) {
        name = result.name
        pokemonName = result.pokemon.name
        baseExperienceYield = result.baseExperienceYield
        baseFriendship = result.baseFriendship
        color = result.color
        familyName = result.familyName
        formIndex = result.formIndex
        game = result.game
        heightInMeters = result.heightInMeters
        index = result.index
        pokedexEntry = result.pokedexEntry
        primaryType = result.primaryType
        secondaryType = result.secondaryType
        species = result.species
        weightInKilograms = result.weightInKilograms
        spriteName = result.spriteName

        baseStats = .init(result.baseStats)
        evolutions = result.evolutions?.map(Evolution.init)
        evYield = .init(result.evYield)
        hiddenAbility = result.hiddenAbility?.toAbility()
        primaryAbility = result.primaryAbility?.toAbility()
        secondaryAbility = result.secondaryAbility?.toAbility()
        pokedexNumbers = .init(pokedexNumbers: result.pokemon.pokedexNumbers)
    }

    public init(
        name: String,
        pokemonName: String,
        baseExperienceYield: Int,
        baseFriendship: Int,
        color: PokemonColor,
        familyName: String,
        formIndex: Int,
        game: Game,
        heightInMeters: Double,
        index: Int,
        pokedexEntry: String,
        primaryType: PokemonType,
        secondaryType: PokemonType?,
        species: String,
        weightInKilograms: Double,
        spriteName: String,
        baseStats: Stats,
        evolutions: [Evolution]?,
        evYield: Stats,
        hiddenAbility: Ability?,
        primaryAbility: Ability?,
        secondaryAbility: Ability?,
        pokedexNumbers: PokedexNumbers
    ) {
        self.name = name
        self.pokemonName = pokemonName
        self.baseExperienceYield = baseExperienceYield
        self.baseFriendship = baseFriendship
        self.color = color
        self.familyName = familyName
        self.formIndex = formIndex
        self.game = game
        self.heightInMeters = heightInMeters
        self.index = index
        self.pokedexEntry = pokedexEntry
        self.primaryType = primaryType
        self.secondaryType = secondaryType
        self.species = species
        self.weightInKilograms = weightInKilograms
        self.spriteName = spriteName
        self.baseStats = baseStats
        self.evolutions = evolutions
        self.evYield = evYield
        self.hiddenAbility = hiddenAbility
        self.primaryAbility = primaryAbility
        self.secondaryAbility = secondaryAbility
        self.pokedexNumbers = pokedexNumbers
    }

}

extension PokemonDetailForm: Codable { }

extension PokemonDetailForm: Hashable { }

private extension StoredAbility {

    func toAbility() -> Ability {
        return .init(result: self)
    }

}
