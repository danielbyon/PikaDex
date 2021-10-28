//
//  PokemonType.swift
//  
//
//  Created by Daniel Byon on 11/17/19.
//

import Foundation

// MARK: - Type
public enum PokemonType: String, CaseIterable {

    case bug = "Bug"
    case dark = "Dark"
    case dragon = "Dragon"
    case electric = "Electric"
    case fairy = "Fairy"
    case fighting = "Fighting"
    case fire = "Fire"
    case flying = "Flying"
    case ghost = "Ghost"
    case grass = "Grass"
    case ground = "Ground"
    case ice = "Ice"
    case normal = "Normal"
    case poison = "Poison"
    case psychic = "Psychic"
    case rock = "Rock"
    case steel = "Steel"
    case water = "Water"

    // The tables only contain non-1x values, if it's missing it's assumed to be 1x
    public static let missingValue = 1.0

    public static func allTypes(for game: Game) -> [PokemonType] { allTypes(for: game.generation) }

    public static func allTypes(for generation: Generation) -> [PokemonType] {
        switch generation {
        case .i:
            return [.bug, .dragon, .electric, .fighting, .fire, .flying, .ghost, .grass, .ground, .ice, .normal, .poison, .psychic, .rock, .water]
        case .ii, .iii, .iv, .v:
            return [.bug, .dark, .dragon, .electric, .fighting, .fire, .flying, .ghost, .grass, .ground, .ice, .normal, .poison, .psychic, .rock, .steel, .water]
        case .vi, .vii, .viii, .all: // TODO: confirm gen 8
            return [.bug, .dark, .dragon, .electric, .fairy, .fighting, .fire, .flying, .ghost, .grass, .ground, .ice, .normal, .poison, .psychic, .rock, .steel, .water]
        }
    }

    public static var allTypesByOrder: [PokemonType] {
        [.normal, .fighting, .flying, .poison, .ground, .rock, .bug, .ghost, .steel, .fire, .water, .grass, .electric, .psychic, .ice, .dragon, .dark, .fairy]
    }

    public subscript(offense opposing: PokemonType, generation: Generation) -> Double {
        offense(for: opposing, generation: generation)
    }

    public subscript(defense opposing: PokemonType, generation: Generation) -> Double {
        defense(for: opposing, generation: generation)
    }

    public func offense(for opposing: PokemonType, generation: Generation) -> Double {
        offenseTable(for: generation)[self]?[opposing] ?? Self.missingValue
    }

    public func defense(for opposing: PokemonType, generation: Generation) -> Double {
        defenseTable(for: generation)[self]?[opposing] ?? Self.missingValue
    }

}

// MARK: - Comparable
extension PokemonType: Comparable {

    public static func < (lhs: PokemonType, rhs: PokemonType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

}

// MARK: - Hashable
extension PokemonType: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }

}

// MARK: - Identifiable
extension PokemonType: Identifiable {

    public var id: String { rawValue }

}

// MARK: - Tables

private typealias TypeTable = [PokemonType: [PokemonType: Double]]

private func offenseTable(for generation: Generation) -> TypeTable {
    offenseTables[generation]!
}

private let offenseTables: [Generation: TypeTable] = [
    .i: _gen1Off,
    .ii: _gen2Off,
    .iii: _gen3Off,
    .iv: _gen4Off,
    .v: _gen5Off,
    .vi: _gen6Off,
    .vii: _gen7Off,
    .viii: _gen8Off,
    .all: _gen8Off
]

// swiftlint:disable colon
// MARK: - Offense Tables

// MARK: Gen 1
private let _gen1Off: TypeTable = [
    .bug:       [.fighting: 0.5, .fire: 0.5, .flying: 0.5, .ghost: 0.5, .grass: 2.0, .poison: 2.0, .psychic: 2.0],
    .dragon:    [.dragon: 2.0],
    .electric:  [.dragon: 0.5, .electric: 0.5, .flying: 2.0, .grass: 0.5, .ground: 0.0, .water: 2.0],
    .fighting:  [.bug: 0.5, .flying: 0.5, .ghost: 0.0, .ice: 2.0, .normal: 2.0, .poison: 0.5, .psychic: 0.5, .rock: 2.0],
    .fire:      [.bug: 2.0, .dragon: 0.5, .fire: 0.5, .grass: 2.0, .ice: 2.0, .rock: 0.5, .water: 0.5],
    .flying:    [.bug: 2.0, .electric: 0.5, .fighting: 2.0, .grass: 2.0, .rock: 0.5],
    .ghost:     [.ghost: 2.0, .normal: 0.0, .psychic: 0.0],
    .grass:     [.bug: 0.5, .dragon: 0.5, .fire: 0.5, .flying: 0.5, .grass: 0.5, .ground: 2.0, .poison: 0.5, .rock: 2.0, .water: 2.0],
    .ground:    [.bug: 0.5, .electric: 2.0, .fire: 2.0, .flying: 0.0, .grass: 0.5, .poison: 2.0, .rock: 2.0],
    .ice:       [.dragon: 2.0, .flying: 2.0, .grass: 2.0, .ground: 2.0, .ice: 0.5, .water: 0.5],
    .normal:    [.ghost: 0.0, .rock: 0.5],
    .poison:    [.bug: 2.0, .ghost: 0.5, .grass: 2.0, .ground: 0.5, .poison: 0.5, .rock: 0.5],
    .psychic:   [.fighting: 2.0, .poison: 2.0, .psychic: 0.5],
    .rock:      [.bug: 2.0, .fighting: 0.5, .fire: 2.0, .flying: 2.0, .ground: 0.5, .ice: 2.0],
    .water:     [.dragon: 0.5, .fire: 2.0, .grass: 0.5, .ground: 2.0, .rock: 2.0, .water: 0.5]
]

// MARK: Gen 2
private let _gen2Off: TypeTable = [
    .bug:       [.dark: 2.0, .fighting: 0.5, .fire: 0.5, .flying: 0.5, .ghost: 0.5, .grass: 2.0, .poison: 0.5, .psychic: 2.0, .steel: 0.5],
    .dark:      [.dark: 0.5, .fighting: 0.5, .ghost: 2.0, .psychic: 2.0, .steel: 0.5],
    .dragon:    [.dragon: 2.0, .steel: 0.5],
    .electric:  [.dragon: 0.5, .electric: 0.5, .flying: 2.0, .grass: 0.5, .ground: 0.0, .water: 2.0],
    .fighting:  [.bug: 0.5, .dark: 2.0, .flying: 0.5, .ghost: 0.0, .ice: 2.0, .normal: 2.0, .poison: 0.5, .psychic: 0.5, .rock: 2.0, .steel: 2.0],
    .fire:      [.bug: 2.0, .dragon: 0.5, .fire: 0.5, .grass: 2.0, .ice: 2.0, .rock: 0.5, .steel: 2.0, .water: 0.5],
    .flying:    [.bug: 2.0, .electric: 0.5, .fighting: 2.0, .grass: 2.0, .rock: 0.5, .steel: 0.5],
    .ghost:     [.dark: 0.5, .ghost: 2.0, .normal: 0.0, .psychic: 2.0, .steel: 0.5],
    .grass:     [.bug: 0.5, .dragon: 0.5, .fire: 0.5, .flying: 0.5, .grass: 0.5, .ground: 2.0, .poison: 0.5, .rock: 2.0, .steel: 0.5, .water: 2.0],
    .ground:    [.bug: 0.5, .electric: 2.0, .fire: 2.0, .flying: 0.0, .grass: 0.5, .poison: 2.0, .rock: 2.0, .steel: 2.0],
    .ice:       [.dragon: 2.0, .fire: 0.5, .flying: 2.0, .grass: 2.0, .ground: 2.0, .ice: 0.5, .steel: 0.5, .water: 0.5],
    .normal:    [.ghost: 0.0, .rock: 0.5, .steel: 0.5],
    .poison:    [.ghost: 0.5, .grass: 2.0, .ground: 0.5, .poison: 0.5, .rock: 0.5, .steel: 0.0],
    .psychic:   [.dark: 0.0, .fighting: 2.0, .poison: 2.0, .psychic: 0.5, .steel: 0.5],
    .rock:      [.bug: 2.0, .fighting: 0.5, .fire: 2.0, .flying: 2.0, .ground: 0.5, .ice: 2.0, .steel: 0.5],
    .steel:     [.electric: 0.5, .fire: 0.5, .ice: 2.0, .rock: 2.0, .steel: 0.5, .water: 0.5],
    .water:     [.dragon: 0.5, .fire: 2.0, .grass: 0.5, .ground: 2.0, .rock: 2.0, .water: 0.5]
]

// MARK: Gen 3
private let _gen3Off: TypeTable = [
    .bug:       [.dark: 2.0, .fighting: 0.5, .fire: 0.5, .flying: 0.5, .ghost: 0.5, .grass: 2.0, .poison: 0.5, .psychic: 2.0, .steel: 0.5],
    .dark:      [.dark: 0.5, .fighting: 0.5, .ghost: 2.0, .psychic: 2.0, .steel: 0.5],
    .dragon:    [.dragon: 2.0, .steel: 0.5],
    .electric:  [.dragon: 0.5, .electric: 0.5, .flying: 2.0, .grass: 0.5, .ground: 0.0, .water: 2.0],
    .fighting:  [.bug: 0.5, .dark: 2.0, .flying: 0.5, .ghost: 0.0, .ice: 2.0, .normal: 2.0, .poison: 0.5, .psychic: 0.5, .rock: 2.0, .steel: 2.0],
    .fire:      [.bug: 2.0, .dragon: 0.5, .fire: 0.5, .grass: 2.0, .ice: 2.0, .rock: 0.5, .steel: 2.0, .water: 0.5],
    .flying:    [.bug: 2.0, .electric: 0.5, .fighting: 2.0, .grass: 2.0, .rock: 0.5, .steel: 0.5],
    .ghost:     [.dark: 0.5, .ghost: 2.0, .normal: 0.0, .psychic: 2.0, .steel: 0.5],
    .grass:     [.bug: 0.5, .dragon: 0.5, .fire: 0.5, .flying: 0.5, .grass: 0.5, .ground: 2.0, .poison: 0.5, .rock: 2.0, .steel: 0.5, .water: 2.0],
    .ground:    [.bug: 0.5, .electric: 2.0, .fire: 2.0, .flying: 0.0, .grass: 0.5, .poison: 2.0, .rock: 2.0, .steel: 2.0],
    .ice:       [.dragon: 2.0, .fire: 0.5, .flying: 2.0, .grass: 2.0, .ground: 2.0, .ice: 0.5, .steel: 0.5, .water: 0.5],
    .normal:    [.ghost: 0.0, .rock: 0.5, .steel: 0.5],
    .poison:    [.ghost: 0.5, .grass: 2.0, .ground: 0.5, .poison: 0.5, .rock: 0.5, .steel: 0.0],
    .psychic:   [.dark: 0.0, .fighting: 2.0, .poison: 2.0, .psychic: 0.5, .steel: 0.5],
    .rock:      [.bug: 2.0, .fighting: 0.5, .fire: 2.0, .flying: 2.0, .ground: 0.5, .ice: 2.0, .steel: 0.5],
    .steel:     [.electric: 0.5, .fire: 0.5, .ice: 2.0, .rock: 2.0, .steel: 0.5, .water: 0.5],
    .water:     [.dragon: 0.5, .fire: 2.0, .grass: 0.5, .ground: 2.0, .rock: 2.0, .water: 0.5]
]

// MARK: Gen 4
private let _gen4Off: TypeTable = [
    .bug:       [.dark: 2.0, .fighting: 0.5, .fire: 0.5, .flying: 0.5, .ghost: 0.5, .grass: 2.0, .poison: 0.5, .psychic: 2.0, .steel: 0.5],
    .dark:      [.dark: 0.5, .fighting: 0.5, .ghost: 2.0, .psychic: 2.0, .steel: 0.5],
    .dragon:    [.dragon: 2.0, .steel: 0.5],
    .electric:  [.dragon: 0.5, .electric: 0.5, .flying: 2.0, .grass: 0.5, .ground: 0.0, .water: 2.0],
    .fighting:  [.bug: 0.5, .dark: 2.0, .flying: 0.5, .ghost: 0.0, .ice: 2.0, .normal: 2.0, .poison: 0.5, .psychic: 0.5, .rock: 2.0, .steel: 2.0],
    .fire:      [.bug: 2.0, .dragon: 0.5, .fire: 0.5, .grass: 2.0, .ice: 2.0, .rock: 0.5, .steel: 2.0, .water: 0.5],
    .flying:    [.bug: 2.0, .electric: 0.5, .fighting: 2.0, .grass: 2.0, .rock: 0.5, .steel: 0.5],
    .ghost:     [.dark: 0.5, .ghost: 2.0, .normal: 0.0, .psychic: 2.0, .steel: 0.5],
    .grass:     [.bug: 0.5, .dragon: 0.5, .fire: 0.5, .flying: 0.5, .grass: 0.5, .ground: 2.0, .poison: 0.5, .rock: 2.0, .steel: 0.5, .water: 2.0],
    .ground:    [.bug: 0.5, .electric: 2.0, .fire: 2.0, .flying: 0.0, .grass: 0.5, .poison: 2.0, .rock: 2.0, .steel: 2.0],
    .ice:       [.dragon: 2.0, .fire: 0.5, .flying: 2.0, .grass: 2.0, .ground: 2.0, .ice: 0.5, .steel: 0.5, .water: 0.5],
    .normal:    [.ghost: 0.0, .rock: 0.5, .steel: 0.5],
    .poison:    [.ghost: 0.5, .grass: 2.0, .ground: 0.5, .poison: 0.5, .rock: 0.5, .steel: 0.0],
    .psychic:   [.dark: 0.0, .fighting: 2.0, .poison: 2.0, .psychic: 0.5, .steel: 0.5],
    .rock:      [.bug: 2.0, .fighting: 0.5, .fire: 2.0, .flying: 2.0, .ground: 0.5, .ice: 2.0, .steel: 0.5],
    .steel:     [.electric: 0.5, .fire: 0.5, .ice: 2.0, .rock: 2.0, .steel: 0.5, .water: 0.5],
    .water:     [.dragon: 0.5, .fire: 2.0, .grass: 0.5, .ground: 2.0, .rock: 2.0, .water: 0.5]
]

// MARK: Gen 5
private let _gen5Off: TypeTable = [
    .bug:       [.dark: 2.0, .fighting: 0.5, .fire: 0.5, .flying: 0.5, .ghost: 0.5, .grass: 2.0, .poison: 0.5, .psychic: 2.0, .steel: 0.5],
    .dark:      [.dark: 0.5, .fighting: 0.5, .ghost: 2.0, .psychic: 2.0, .steel: 0.5],
    .dragon:    [.dragon: 2.0, .steel: 0.5],
    .electric:  [.dragon: 0.5, .electric: 0.5, .flying: 2.0, .grass: 0.5, .ground: 0.0, .water: 2.0],
    .fighting:  [.bug: 0.5, .dark: 2.0, .flying: 0.5, .ghost: 0.0, .ice: 2.0, .normal: 2.0, .poison: 0.5, .psychic: 0.5, .rock: 2.0, .steel: 2.0],
    .fire:      [.bug: 2.0, .dragon: 0.5, .fire: 0.5, .grass: 2.0, .ice: 2.0, .rock: 0.5, .steel: 2.0, .water: 0.5],
    .flying:    [.bug: 2.0, .electric: 0.5, .fighting: 2.0, .grass: 2.0, .rock: 0.5, .steel: 0.5],
    .ghost:     [.dark: 0.5, .ghost: 2.0, .normal: 0.0, .psychic: 2.0, .steel: 0.5],
    .grass:     [.bug: 0.5, .dragon: 0.5, .fire: 0.5, .flying: 0.5, .grass: 0.5, .ground: 2.0, .poison: 0.5, .rock: 2.0, .steel: 0.5, .water: 2.0],
    .ground:    [.bug: 0.5, .electric: 2.0, .fire: 2.0, .flying: 0.0, .grass: 0.5, .poison: 2.0, .rock: 2.0, .steel: 2.0],
    .ice:       [.dragon: 2.0, .fire: 0.5, .flying: 2.0, .grass: 2.0, .ground: 2.0, .ice: 0.5, .steel: 0.5, .water: 0.5],
    .normal:    [.ghost: 0.0, .rock: 0.5, .steel: 0.5],
    .poison:    [.ghost: 0.5, .grass: 2.0, .ground: 0.5, .poison: 0.5, .rock: 0.5, .steel: 0.0],
    .psychic:   [.dark: 0.0, .fighting: 2.0, .poison: 2.0, .psychic: 0.5, .steel: 0.5],
    .rock:      [.bug: 2.0, .fighting: 0.5, .fire: 2.0, .flying: 2.0, .ground: 0.5, .ice: 2.0, .steel: 0.5],
    .steel:     [.electric: 0.5, .fire: 0.5, .ice: 2.0, .rock: 2.0, .steel: 0.5, .water: 0.5],
    .water:     [.dragon: 0.5, .fire: 2.0, .grass: 0.5, .ground: 2.0, .rock: 2.0, .water: 0.5]
]

// MARK: Gen 6
private let _gen6Off: TypeTable = [
    .bug:       [.dark: 2.0, .fairy: 0.5, .fighting: 0.5, .fire: 0.5, .flying: 0.5, .ghost: 0.5, .grass: 2.0, .poison: 0.5, .psychic: 2.0, .steel: 0.5],
    .dark:      [.dark: 0.5, .fairy: 0.5, .fighting: 0.5, .ghost: 2.0, .psychic: 2.0],
    .dragon:    [.dragon: 2.0, .fairy: 0.0, .steel: 0.5],
    .electric:  [.dragon: 0.5, .electric: 0.5, .flying: 2.0, .grass: 0.5, .ground: 0.0, .water: 2.0],
    .fairy:     [.dark: 2.0, .dragon: 2.0, .fighting: 2.0, .fire: 0.5, .poison: 0.5, .steel: 0.5],
    .fighting:  [.bug: 0.5, .dark: 2.0, .fairy: 0.5, .flying: 0.5, .ghost: 0.0, .ice: 2.0, .normal: 2.0, .poison: 0.5, .psychic: 0.5, .rock: 2.0, .steel: 2.0],
    .fire:      [.bug: 2.0, .dragon: 0.5, .fire: 0.5, .grass: 2.0, .ice: 2.0, .rock: 0.5, .steel: 2.0, .water: 0.5],
    .flying:    [.bug: 2.0, .electric: 0.5, .fighting: 2.0, .grass: 2.0, .rock: 0.5, .steel: 0.5],
    .ghost:     [.dark: 0.5, .ghost: 2.0, .normal: 0.0, .psychic: 2.0],
    .grass:     [.bug: 0.5, .dragon: 0.5, .fire: 0.5, .flying: 0.5, .grass: 0.5, .ground: 2.0, .poison: 0.5, .rock: 2.0, .steel: 0.5, .water: 2.0],
    .ground:    [.bug: 0.5, .electric: 2.0, .fire: 2.0, .flying: 0.0, .grass: 0.5, .poison: 2.0, .rock: 2.0, .steel: 2.0],
    .ice:       [.dragon: 2.0, .fire: 0.5, .flying: 2.0, .grass: 2.0, .ground: 2.0, .ice: 0.5, .steel: 0.5, .water: 0.5],
    .normal:    [.ghost: 0.0, .rock: 0.5, .steel: 0.5],
    .poison:    [.fairy: 2.0, .ghost: 0.5, .grass: 2.0, .ground: 0.5, .poison: 0.5, .rock: 0.5, .steel: 0.0],
    .psychic:   [.dark: 0.0, .fighting: 2.0, .poison: 2.0, .psychic: 0.5, .steel: 0.5],
    .rock:      [.bug: 2.0, .fighting: 0.5, .fire: 2.0, .flying: 2.0, .ground: 0.5, .ice: 2.0, .steel: 0.5],
    .steel:     [.electric: 0.5, .fairy: 2.0, .fire: 0.5, .ice: 2.0, .rock: 2.0, .steel: 0.5, .water: 0.5],
    .water:     [.dragon: 0.5, .fire: 2.0, .grass: 0.5, .ground: 2.0, .rock: 2.0, .water: 0.5]
]

// MARK: Gen 7
private let _gen7Off: TypeTable = [
    .bug:       [.dark: 2.0, .fairy: 0.5, .fighting: 0.5, .fire: 0.5, .flying: 0.5, .ghost: 0.5, .grass: 2.0, .poison: 0.5, .psychic: 2.0, .steel: 0.5],
    .dark:      [.dark: 0.5, .fairy: 0.5, .fighting: 0.5, .ghost: 2.0, .psychic: 2.0],
    .dragon:    [.dragon: 2.0, .fairy: 0.0, .steel: 0.5],
    .electric:  [.dragon: 0.5, .electric: 0.5, .flying: 2.0, .grass: 0.5, .ground: 0.0, .water: 2.0],
    .fairy:     [.dark: 2.0, .dragon: 2.0, .fighting: 2.0, .fire: 0.5, .poison: 0.5, .steel: 0.5],
    .fighting:  [.bug: 0.5, .dark: 2.0, .fairy: 0.5, .flying: 0.5, .ghost: 0.0, .ice: 2.0, .normal: 2.0, .poison: 0.5, .psychic: 0.5, .rock: 2.0, .steel: 2.0],
    .fire:      [.bug: 2.0, .dragon: 0.5, .fire: 0.5, .grass: 2.0, .ice: 2.0, .rock: 0.5, .steel: 2.0, .water: 0.5],
    .flying:    [.bug: 2.0, .electric: 0.5, .fighting: 2.0, .grass: 2.0, .rock: 0.5, .steel: 0.5],
    .ghost:     [.dark: 0.5, .ghost: 2.0, .normal: 0.0, .psychic: 2.0],
    .grass:     [.bug: 0.5, .dragon: 0.5, .fire: 0.5, .flying: 0.5, .grass: 0.5, .ground: 2.0, .poison: 0.5, .rock: 2.0, .steel: 0.5, .water: 2.0],
    .ground:    [.bug: 0.5, .electric: 2.0, .fire: 2.0, .flying: 0.0, .grass: 0.5, .poison: 2.0, .rock: 2.0, .steel: 2.0],
    .ice:       [.dragon: 2.0, .fire: 0.5, .flying: 2.0, .grass: 2.0, .ground: 2.0, .ice: 0.5, .steel: 0.5, .water: 0.5],
    .normal:    [.ghost: 0.0, .rock: 0.5, .steel: 0.5],
    .poison:    [.fairy: 2.0, .ghost: 0.5, .grass: 2.0, .ground: 0.5, .poison: 0.5, .rock: 0.5, .steel: 0.0],
    .psychic:   [.dark: 0.0, .fighting: 2.0, .poison: 2.0, .psychic: 0.5, .steel: 0.5],
    .rock:      [.bug: 2.0, .fighting: 0.5, .fire: 2.0, .flying: 2.0, .ground: 0.5, .ice: 2.0, .steel: 0.5],
    .steel:     [.electric: 0.5, .fairy: 2.0, .fire: 0.5, .ice: 2.0, .rock: 2.0, .steel: 0.5, .water: 0.5],
    .water:     [.dragon: 0.5, .fire: 2.0, .grass: 0.5, .ground: 2.0, .rock: 2.0, .water: 0.5]
]

// MARK: Gen 8
private let _gen8Off: TypeTable = [
    .bug:       [.dark: 2.0, .fairy: 0.5, .fighting: 0.5, .fire: 0.5, .flying: 0.5, .ghost: 0.5, .grass: 2.0, .poison: 0.5, .psychic: 2.0, .steel: 0.5],
    .dark:      [.dark: 0.5, .fairy: 0.5, .fighting: 0.5, .ghost: 2.0, .psychic: 2.0],
    .dragon:    [.dragon: 2.0, .fairy: 0.0, .steel: 0.5],
    .electric:  [.dragon: 0.5, .electric: 0.5, .flying: 2.0, .grass: 0.5, .ground: 0.0, .water: 2.0],
    .fairy:     [.dark: 2.0, .dragon: 2.0, .fighting: 2.0, .fire: 0.5, .poison: 0.5, .steel: 0.5],
    .fighting:  [.bug: 0.5, .dark: 2.0, .fairy: 0.5, .flying: 0.5, .ghost: 0.0, .ice: 2.0, .normal: 2.0, .poison: 0.5, .psychic: 0.5, .rock: 2.0, .steel: 2.0],
    .fire:      [.bug: 2.0, .dragon: 0.5, .fire: 0.5, .grass: 2.0, .ice: 2.0, .rock: 0.5, .steel: 2.0, .water: 0.5],
    .flying:    [.bug: 2.0, .electric: 0.5, .fighting: 2.0, .grass: 2.0, .rock: 0.5, .steel: 0.5],
    .ghost:     [.dark: 0.5, .ghost: 2.0, .normal: 0.0, .psychic: 2.0],
    .grass:     [.bug: 0.5, .dragon: 0.5, .fire: 0.5, .flying: 0.5, .grass: 0.5, .ground: 2.0, .poison: 0.5, .rock: 2.0, .steel: 0.5, .water: 2.0],
    .ground:    [.bug: 0.5, .electric: 2.0, .fire: 2.0, .flying: 0.0, .grass: 0.5, .poison: 2.0, .rock: 2.0, .steel: 2.0],
    .ice:       [.dragon: 2.0, .fire: 0.5, .flying: 2.0, .grass: 2.0, .ground: 2.0, .ice: 0.5, .steel: 0.5, .water: 0.5],
    .normal:    [.ghost: 0.0, .rock: 0.5, .steel: 0.5],
    .poison:    [.fairy: 2.0, .ghost: 0.5, .grass: 2.0, .ground: 0.5, .poison: 0.5, .rock: 0.5, .steel: 0.0],
    .psychic:   [.dark: 0.0, .fighting: 2.0, .poison: 2.0, .psychic: 0.5, .steel: 0.5],
    .rock:      [.bug: 2.0, .fighting: 0.5, .fire: 2.0, .flying: 2.0, .ground: 0.5, .ice: 2.0, .steel: 0.5],
    .steel:     [.electric: 0.5, .fairy: 2.0, .fire: 0.5, .ice: 2.0, .rock: 2.0, .steel: 0.5, .water: 0.5],
    .water:     [.dragon: 0.5, .fire: 2.0, .grass: 0.5, .ground: 2.0, .rock: 2.0, .water: 0.5]
]

// MARK: - Defense Tables

private func defenseTable(for generation: Generation) -> TypeTable {
    defenseTables[generation]!
}

private let defenseTables: [Generation: TypeTable] = [
    .i: _gen1Def,
    .ii: _gen2Def,
    .iii: _gen3Def,
    .iv: _gen4Def,
    .v: _gen5Def,
    .vi: _gen6Def,
    .vii: _gen7Def,
    .viii: _gen8Def,
    .all: _gen8Def
]

// MARK: Gen 1
private let _gen1Def: TypeTable = [
    .bug:       [.fighting: 0.5, .fire: 2.0, .flying: 2.0, .grass: 0.5, .ground: 0.5, .poison: 2.0, .rock: 2.0],
    .dragon:    [.dragon: 2.0, .electric: 0.5, .fire: 0.5, .grass: 0.5, .ice: 2.0, .water: 0.5],
    .electric:  [.electric: 0.5, .flying: 0.5, .ground: 2.0],
    .fighting:  [.bug: 0.5, .flying: 2.0, .psychic: 2.0, .rock: 0.5],
    .fire:      [.bug: 0.5, .fire: 0.5, .grass: 0.5, .ground: 2.0, .rock: 2.0, .water: 2.0],
    .flying:    [.bug: 0.5, .electric: 2.0, .fighting: 0.5, .grass: 0.5, .ground: 0.0, .ice: 2.0, .rock: 2.0],
    .ghost:     [.bug: 0.5, .fighting: 0.0, .ghost: 2.0, .normal: 0.0, .poison: 0.5],
    .grass:     [.bug: 2.0, .electric: 0.5, .fire: 2.0, .flying: 2.0, .grass: 0.5, .ground: 0.5, .ice: 2.0, .poison: 2.0, .water: 0.5],
    .ground:    [.electric: 0.0, .grass: 2.0, .ice: 2.0, .poison: 0.5, .rock: 0.5, .water: 2.0],
    .ice:       [.fighting: 2.0, .fire: 2.0, .ice: 0.5, .rock: 2.0],
    .normal:    [.fighting: 2.0, .ghost: 0.0],
    .poison:    [.bug: 2.0, .fighting: 0.5, .grass: 0.5, .ground: 2.0, .poison: 0.5, .psychic: 2.0],
    .psychic:   [.bug: 2.0, .fighting: 0.5, .ghost: 0.0, .psychic: 0.5],
    .rock:      [.fighting: 2.0, .fire: 0.5, .flying: 0.5, .grass: 2.0, .ground: 2.0, .normal: 0.5, .poison: 0.5, .water: 2.0],
    .water:     [.electric: 2.0, .fire: 0.5, .grass: 2.0, .ice: 0.5, .water: 0.5]
]

// MARK: Gen 2
private let _gen2Def: TypeTable = [
    .bug:       [.fighting: 0.5, .fire: 2.0, .flying: 2.0, .grass: 0.5, .ground: 0.5, .rock: 2.0],
    .dark:       [.bug: 2.0, .dark: 0.5, .fighting: 2.0, .ghost: 0.5, .psychic: 0.0],
    .dragon:       [.dragon: 2.0, .electric: 0.5, .fire: 0.5, .grass: 0.5, .ice: 2.0, .water: 0.5],
    .electric:       [.electric: 0.5, .flying: 0.5, .ground: 2.0, .steel: 0.5],
    .fighting:       [.bug: 0.5, .dark: 0.5, .flying: 2.0, .psychic: 2.0, .rock: 0.5],
    .fire:       [.bug: 0.5, .fire: 0.5, .grass: 0.5, .ground: 2.0, .ice: 0.5, .rock: 2.0, .steel: 0.5, .water: 2.0],
    .flying:       [.bug: 0.5, .electric: 2.0, .fighting: 0.5, .grass: 0.5, .ground: 0.0, .ice: 2.0, .rock: 2.0],
    .ghost:       [.bug: 0.5, .dark: 2.0, .fighting: 0.0, .ghost: 2.0, .normal: 0.0, .poison: 0.5],
    .grass:       [.bug: 2.0, .electric: 0.5, .fire: 2.0, .flying: 2.0, .grass: 0.5, .ground: 0.5, .ice: 2.0, .poison: 2.0, .water: 0.5],
    .ground:       [.electric: 0.0, .grass: 2.0, .ice: 2.0, .poison: 0.5, .rock: 0.5, .water: 2.0],
    .ice:       [.fighting: 2.0, .fire: 2.0, .ice: 0.5, .rock: 2.0, .steel: 2.0],
    .normal:       [.fighting: 2.0, .ghost: 0.0],
    .poison:       [.bug: 0.5, .fighting: 0.5, .grass: 0.5, .ground: 2.0, .poison: 0.5, .psychic: 2.0],
    .psychic:       [.bug: 2.0, .dark: 2.0, .fighting: 0.5, .ghost: 2.0, .psychic: 0.5],
    .rock:       [.fighting: 2.0, .fire: 0.5, .flying: 0.5, .grass: 2.0, .ground: 2.0, .normal: 0.5, .poison: 0.5, .steel: 2.0, .water: 2.0],
    .steel:       [.bug: 0.5, .dark: 0.5, .dragon: 0.5, .fighting: 2.0, .fire: 2.0, .flying: 0.5, .ghost: 0.5, .grass: 0.5, .ground: 2.0, .ice: 0.5, .normal: 0.5, .poison: 0.0, .psychic: 0.5, .rock: 0.5, .steel: 0.5],
    .water:       [.electric: 2.0, .fire: 0.5, .grass: 2.0, .ice: 0.5, .steel: 0.5, .water: 0.5]
]

// MARK: Gen 3
private let _gen3Def: TypeTable = [
    .bug:       [.fighting: 0.5, .fire: 2.0, .flying: 2.0, .grass: 0.5, .ground: 0.5, .rock: 2.0],
    .dark:       [.bug: 2.0, .dark: 0.5, .fighting: 2.0, .ghost: 0.5, .psychic: 0.0],
    .dragon:       [.dragon: 2.0, .electric: 0.5, .fire: 0.5, .grass: 0.5, .ice: 2.0, .water: 0.5],
    .electric:       [.electric: 0.5, .flying: 0.5, .ground: 2.0, .steel: 0.5],
    .fighting:       [.bug: 0.5, .dark: 0.5, .flying: 2.0, .psychic: 2.0, .rock: 0.5],
    .fire:       [.bug: 0.5, .fire: 0.5, .grass: 0.5, .ground: 2.0, .ice: 0.5, .rock: 2.0, .steel: 0.5, .water: 2.0],
    .flying:       [.bug: 0.5, .electric: 2.0, .fighting: 0.5, .grass: 0.5, .ground: 0.0, .ice: 2.0, .rock: 2.0],
    .ghost:       [.bug: 0.5, .dark: 2.0, .fighting: 0.0, .ghost: 2.0, .normal: 0.0, .poison: 0.5],
    .grass:       [.bug: 2.0, .electric: 0.5, .fire: 2.0, .flying: 2.0, .grass: 0.5, .ground: 0.5, .ice: 2.0, .poison: 2.0, .water: 0.5],
    .ground:       [.electric: 0.0, .grass: 2.0, .ice: 2.0, .poison: 0.5, .rock: 0.5, .water: 2.0],
    .ice:       [.fighting: 2.0, .fire: 2.0, .ice: 0.5, .rock: 2.0, .steel: 2.0],
    .normal:       [.fighting: 2.0, .ghost: 0.0],
    .poison:       [.bug: 0.5, .fighting: 0.5, .grass: 0.5, .ground: 2.0, .poison: 0.5, .psychic: 2.0],
    .psychic:       [.bug: 2.0, .dark: 2.0, .fighting: 0.5, .ghost: 2.0, .psychic: 0.5],
    .rock:       [.fighting: 2.0, .fire: 0.5, .flying: 0.5, .grass: 2.0, .ground: 2.0, .normal: 0.5, .poison: 0.5, .steel: 2.0, .water: 2.0],
    .steel:       [.bug: 0.5, .dark: 0.5, .dragon: 0.5, .fighting: 2.0, .fire: 2.0, .flying: 0.5, .ghost: 0.5, .grass: 0.5, .ground: 2.0, .ice: 0.5, .normal: 0.5, .poison: 0.0, .psychic: 0.5, .rock: 0.5, .steel: 0.5],
    .water:       [.electric: 2.0, .fire: 0.5, .grass: 2.0, .ice: 0.5, .steel: 0.5, .water: 0.5]
]

// MARK: Gen 4
private let _gen4Def: TypeTable = [
    .bug:       [.fighting: 0.5, .fire: 2.0, .flying: 2.0, .grass: 0.5, .ground: 0.5, .rock: 2.0],
    .dark:       [.bug: 2.0, .dark: 0.5, .fighting: 2.0, .ghost: 0.5, .psychic: 0.0],
    .dragon:       [.dragon: 2.0, .electric: 0.5, .fire: 0.5, .grass: 0.5, .ice: 2.0, .water: 0.5],
    .electric:       [.electric: 0.5, .flying: 0.5, .ground: 2.0, .steel: 0.5],
    .fighting:       [.bug: 0.5, .dark: 0.5, .flying: 2.0, .psychic: 2.0, .rock: 0.5],
    .fire:       [.bug: 0.5, .fire: 0.5, .grass: 0.5, .ground: 2.0, .ice: 0.5, .rock: 2.0, .steel: 0.5, .water: 2.0],
    .flying:       [.bug: 0.5, .electric: 2.0, .fighting: 0.5, .grass: 0.5, .ground: 0.0, .ice: 2.0, .rock: 2.0],
    .ghost:       [.bug: 0.5, .dark: 2.0, .fighting: 0.0, .ghost: 2.0, .normal: 0.0, .poison: 0.5],
    .grass:       [.bug: 2.0, .electric: 0.5, .fire: 2.0, .flying: 2.0, .grass: 0.5, .ground: 0.5, .ice: 2.0, .poison: 2.0, .water: 0.5],
    .ground:       [.electric: 0.0, .grass: 2.0, .ice: 2.0, .poison: 0.5, .rock: 0.5, .water: 2.0],
    .ice:       [.fighting: 2.0, .fire: 2.0, .ice: 0.5, .rock: 2.0, .steel: 2.0],
    .normal:       [.fighting: 2.0, .ghost: 0.0],
    .poison:       [.bug: 0.5, .fighting: 0.5, .grass: 0.5, .ground: 2.0, .poison: 0.5, .psychic: 2.0],
    .psychic:       [.bug: 2.0, .dark: 2.0, .fighting: 0.5, .ghost: 2.0, .psychic: 0.5],
    .rock:       [.fighting: 2.0, .fire: 0.5, .flying: 0.5, .grass: 2.0, .ground: 2.0, .normal: 0.5, .poison: 0.5, .steel: 2.0, .water: 2.0],
    .steel:       [.bug: 0.5, .dark: 0.5, .dragon: 0.5, .fighting: 2.0, .fire: 2.0, .flying: 0.5, .ghost: 0.5, .grass: 0.5, .ground: 2.0, .ice: 0.5, .normal: 0.5, .poison: 0.0, .psychic: 0.5, .rock: 0.5, .steel: 0.5],
    .water:       [.electric: 2.0, .fire: 0.5, .grass: 2.0, .ice: 0.5, .steel: 0.5, .water: 0.5]
]

// MARK: Gen 5
private let _gen5Def: TypeTable = [
    .bug:       [.fighting: 0.5, .fire: 2.0, .flying: 2.0, .grass: 0.5, .ground: 0.5, .rock: 2.0],
    .dark:       [.bug: 2.0, .dark: 0.5, .fighting: 2.0, .ghost: 0.5, .psychic: 0.0],
    .dragon:       [.dragon: 2.0, .electric: 0.5, .fire: 0.5, .grass: 0.5, .ice: 2.0, .water: 0.5],
    .electric:       [.electric: 0.5, .flying: 0.5, .ground: 2.0, .steel: 0.5],
    .fighting:       [.bug: 0.5, .dark: 0.5, .flying: 2.0, .psychic: 2.0, .rock: 0.5],
    .fire:       [.bug: 0.5, .fire: 0.5, .grass: 0.5, .ground: 2.0, .ice: 0.5, .rock: 2.0, .steel: 0.5, .water: 2.0],
    .flying:       [.bug: 0.5, .electric: 2.0, .fighting: 0.5, .grass: 0.5, .ground: 0.0, .ice: 2.0, .rock: 2.0],
    .ghost:       [.bug: 0.5, .dark: 2.0, .fighting: 0.0, .ghost: 2.0, .normal: 0.0, .poison: 0.5],
    .grass:       [.bug: 2.0, .electric: 0.5, .fire: 2.0, .flying: 2.0, .grass: 0.5, .ground: 0.5, .ice: 2.0, .poison: 2.0, .water: 0.5],
    .ground:       [.electric: 0.0, .grass: 2.0, .ice: 2.0, .poison: 0.5, .rock: 0.5, .water: 2.0],
    .ice:       [.fighting: 2.0, .fire: 2.0, .ice: 0.5, .rock: 2.0, .steel: 2.0],
    .normal:       [.fighting: 2.0, .ghost: 0.0],
    .poison:       [.bug: 0.5, .fighting: 0.5, .grass: 0.5, .ground: 2.0, .poison: 0.5, .psychic: 2.0],
    .psychic:       [.bug: 2.0, .dark: 2.0, .fighting: 0.5, .ghost: 2.0, .psychic: 0.5],
    .rock:       [.fighting: 2.0, .fire: 0.5, .flying: 0.5, .grass: 2.0, .ground: 2.0, .normal: 0.5, .poison: 0.5, .steel: 2.0, .water: 2.0],
    .steel:       [.bug: 0.5, .dark: 0.5, .dragon: 0.5, .fighting: 2.0, .fire: 2.0, .flying: 0.5, .ghost: 0.5, .grass: 0.5, .ground: 2.0, .ice: 0.5, .normal: 0.5, .poison: 0.0, .psychic: 0.5, .rock: 0.5, .steel: 0.5],
    .water:       [.electric: 2.0, .fire: 0.5, .grass: 2.0, .ice: 0.5, .steel: 0.5, .water: 0.5]
]

// MARK: Gen 6
private let _gen6Def: TypeTable = [
    .bug:       [.fighting: 0.5, .fire: 2.0, .flying: 2.0, .grass: 0.5, .ground: 0.5, .rock: 2.0],
    .dark:       [.bug: 2.0, .dark: 0.5, .fairy: 2.0, .fighting: 2.0, .ghost: 0.5, .psychic: 0.0],
    .dragon:       [.dragon: 2.0, .electric: 0.5, .fairy: 2.0, .fire: 0.5, .grass: 0.5, .ice: 2.0, .water: 0.5],
    .electric:       [.electric: 0.5, .flying: 0.5, .ground: 2.0, .steel: 0.5],
    .fairy:       [.bug: 0.5, .dark: 0.5, .dragon: 0.0, .fighting: 0.5, .poison: 2.0, .steel: 2.0],
    .fighting:       [.bug: 0.5, .dark: 0.5, .fairy: 2.0, .flying: 2.0, .psychic: 2.0, .rock: 0.5],
    .fire:       [.bug: 0.5, .fairy: 0.5, .fire: 0.5, .grass: 0.5, .ground: 2.0, .ice: 0.5, .rock: 2.0, .steel: 0.5, .water: 2.0],
    .flying:       [.bug: 0.5, .electric: 2.0, .fighting: 0.5, .grass: 0.5, .ground: 0.0, .ice: 2.0, .rock: 2.0],
    .ghost:       [.bug: 0.5, .dark: 2.0, .fighting: 0.0, .ghost: 2.0, .normal: 0.0, .poison: 0.5],
    .grass:       [.bug: 2.0, .electric: 0.5, .fire: 2.0, .flying: 2.0, .grass: 0.5, .ground: 0.5, .ice: 2.0, .poison: 2.0, .water: 0.5],
    .ground:       [.electric: 0.0, .grass: 2.0, .ice: 2.0, .poison: 0.5, .rock: 0.5, .water: 2.0],
    .ice:       [.fighting: 2.0, .fire: 2.0, .ice: 0.5, .rock: 2.0, .steel: 2.0],
    .normal:       [.fighting: 2.0, .ghost: 0.0],
    .poison:       [.bug: 0.5, .fairy: 0.5, .fighting: 0.5, .grass: 0.5, .ground: 2.0, .poison: 0.5, .psychic: 2.0],
    .psychic:       [.bug: 2.0, .dark: 2.0, .fighting: 0.5, .ghost: 2.0, .psychic: 0.5],
    .rock:       [.fighting: 2.0, .fire: 0.5, .flying: 0.5, .grass: 2.0, .ground: 2.0, .normal: 0.5, .poison: 0.5, .steel: 2.0, .water: 2.0],
    .steel:       [.bug: 0.5, .dragon: 0.5, .fairy: 0.5, .fighting: 2.0, .fire: 2.0, .flying: 0.5, .grass: 0.5, .ground: 2.0, .ice: 0.5, .normal: 0.5, .poison: 0.0, .psychic: 0.5, .rock: 0.5, .steel: 0.5],
    .water:       [.electric: 2.0, .fire: 0.5, .grass: 2.0, .ice: 0.5, .steel: 0.5, .water: 0.5]
]

// MARK: Gen 7
private let _gen7Def: TypeTable = [
    .bug:       [.fighting: 0.5, .fire: 2.0, .flying: 2.0, .grass: 0.5, .ground: 0.5, .rock: 2.0],
    .dark:      [.bug: 2.0, .dark: 0.5, .fairy: 2.0, .fighting: 2.0, .ghost: 0.5, .psychic: 0.0],
    .dragon:    [.dragon: 2.0, .electric: 0.5, .fairy: 2.0, .fire: 0.5, .grass: 0.5, .ice: 2.0, .water: 0.5],
    .electric:  [.electric: 0.5, .flying: 0.5, .ground: 2.0, .steel: 0.5],
    .fairy:     [.bug: 0.5, .dark: 0.5, .dragon: 0.0, .fighting: 0.5, .poison: 2.0, .steel: 2.0],
    .fighting:  [.bug: 0.5, .dark: 0.5, .fairy: 2.0, .flying: 2.0, .psychic: 2.0, .rock: 0.5],
    .fire:      [.bug: 0.5, .fairy: 0.5, .fire: 0.5, .grass: 0.5, .ground: 2.0, .ice: 0.5, .rock: 2.0, .steel: 0.5, .water: 2.0],
    .flying:    [.bug: 0.5, .electric: 2.0, .fighting: 0.5, .grass: 0.5, .ground: 0.0, .ice: 2.0, .rock: 2.0],
    .ghost:     [.bug: 0.5, .dark: 2.0, .fighting: 0.0, .ghost: 2.0, .normal: 0.0, .poison: 0.5],
    .grass:     [.bug: 2.0, .electric: 0.5, .fire: 2.0, .flying: 2.0, .grass: 0.5, .ground: 0.5, .ice: 2.0, .poison: 2.0, .water: 0.5],
    .ground:    [.electric: 0.0, .grass: 2.0, .ice: 2.0, .poison: 0.5, .rock: 0.5, .water: 2.0],
    .ice:       [.fighting: 2.0, .fire: 2.0, .ice: 0.5, .rock: 2.0, .steel: 2.0],
    .normal:    [.fighting: 2.0, .ghost: 0.0],
    .poison:    [.bug: 0.5, .fairy: 0.5, .fighting: 0.5, .grass: 0.5, .ground: 2.0, .poison: 0.5, .psychic: 2.0],
    .psychic:   [.bug: 2.0, .dark: 2.0, .fighting: 0.5, .ghost: 2.0, .psychic: 0.5],
    .rock:      [.fighting: 2.0, .fire: 0.5, .flying: 0.5, .grass: 2.0, .ground: 2.0, .normal: 0.5, .poison: 0.5, .steel: 2.0, .water: 2.0],
    .steel:     [.bug: 0.5, .dragon: 0.5, .fairy: 0.5, .fighting: 2.0, .fire: 2.0, .flying: 0.5, .grass: 0.5, .ground: 2.0, .ice: 0.5, .normal: 0.5, .poison: 0.0, .psychic: 0.5, .rock: 0.5, .steel: 0.5],
    .water:     [.electric: 2.0, .fire: 0.5, .grass: 2.0, .ice: 0.5, .steel: 0.5, .water: 0.5]
]

// MARK: Gen 8
private let _gen8Def: TypeTable = [
    .bug:       [.fighting: 0.5, .fire: 2.0, .flying: 2.0, .grass: 0.5, .ground: 0.5, .rock: 2.0],
    .dark:      [.bug: 2.0, .dark: 0.5, .fairy: 2.0, .fighting: 2.0, .ghost: 0.5, .psychic: 0.0],
    .dragon:    [.dragon: 2.0, .electric: 0.5, .fairy: 2.0, .fire: 0.5, .grass: 0.5, .ice: 2.0, .water: 0.5],
    .electric:  [.electric: 0.5, .flying: 0.5, .ground: 2.0, .steel: 0.5],
    .fairy:     [.bug: 0.5, .dark: 0.5, .dragon: 0.0, .fighting: 0.5, .poison: 2.0, .steel: 2.0],
    .fighting:  [.bug: 0.5, .dark: 0.5, .fairy: 2.0, .flying: 2.0, .psychic: 2.0, .rock: 0.5],
    .fire:      [.bug: 0.5, .fairy: 0.5, .fire: 0.5, .grass: 0.5, .ground: 2.0, .ice: 0.5, .rock: 2.0, .steel: 0.5, .water: 2.0],
    .flying:    [.bug: 0.5, .electric: 2.0, .fighting: 0.5, .grass: 0.5, .ground: 0.0, .ice: 2.0, .rock: 2.0],
    .ghost:     [.bug: 0.5, .dark: 2.0, .fighting: 0.0, .ghost: 2.0, .normal: 0.0, .poison: 0.5],
    .grass:     [.bug: 2.0, .electric: 0.5, .fire: 2.0, .flying: 2.0, .grass: 0.5, .ground: 0.5, .ice: 2.0, .poison: 2.0, .water: 0.5],
    .ground:    [.electric: 0.0, .grass: 2.0, .ice: 2.0, .poison: 0.5, .rock: 0.5, .water: 2.0],
    .ice:       [.fighting: 2.0, .fire: 2.0, .ice: 0.5, .rock: 2.0, .steel: 2.0],
    .normal:    [.fighting: 2.0, .ghost: 0.0],
    .poison:    [.bug: 0.5, .fairy: 0.5, .fighting: 0.5, .grass: 0.5, .ground: 2.0, .poison: 0.5, .psychic: 2.0],
    .psychic:   [.bug: 2.0, .dark: 2.0, .fighting: 0.5, .ghost: 2.0, .psychic: 0.5],
    .rock:      [.fighting: 2.0, .fire: 0.5, .flying: 0.5, .grass: 2.0, .ground: 2.0, .normal: 0.5, .poison: 0.5, .steel: 2.0, .water: 2.0],
    .steel:     [.bug: 0.5, .dragon: 0.5, .fairy: 0.5, .fighting: 2.0, .fire: 2.0, .flying: 0.5, .grass: 0.5, .ground: 2.0, .ice: 0.5, .normal: 0.5, .poison: 0.0, .psychic: 0.5, .rock: 0.5, .steel: 0.5],
    .water:     [.electric: 2.0, .fire: 0.5, .grass: 2.0, .ice: 0.5, .steel: 0.5, .water: 0.5]
]
// swiftlint:enable colon
