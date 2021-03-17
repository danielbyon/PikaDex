//
//  FormInfo+Extensions.swift
//  Database
//
//  Created by Daniel Byon on 12/18/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Fetch Requests
public extension PokemonForm {

    static func fetchRequest(for ability: Ability, game: Game) -> NSFetchRequest<PokemonForm> {
        let abilityIndex = Int32(ability.index)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "\(#keyPath(PokemonForm.i_gameIndex)) == %d", game.index),
            NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate(format: "\(#keyPath(PokemonForm.i_primaryAbilityIndex)) == %d", abilityIndex),
                NSPredicate(format: "\(#keyPath(PokemonForm.i_secondaryAbilityIndex)) == %d", abilityIndex),
                NSPredicate(format: "\(#keyPath(PokemonForm.i_hiddenAbilityIndex)) == %d", abilityIndex)
            ])
        ])
        return makeFetchRequest(with: predicate)
    }

    static func fetchRequest(forType type: PokemonType, game: Game) -> NSFetchRequest<PokemonForm> {
        let predicate = NSPredicate(format: "\(#keyPath(PokemonForm.z_game)) == %@ AND (\(#keyPath(PokemonForm.z_primaryType)) == %@ OR \(#keyPath(PokemonForm.z_secondaryType)) == %@)", game.rawValue, type.rawValue, type.rawValue)
        return makeFetchRequest(with: predicate)
    }

    static func fetchRequest(forFirstType firstType: PokemonType, secondType: PokemonType, game: Game) -> NSFetchRequest<PokemonForm> {
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "\(#keyPath(PokemonForm.z_game)) == %@", game.rawValue),
            NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSCompoundPredicate(andPredicateWithSubpredicates: [
                    NSPredicate(format: "\(#keyPath(PokemonForm.z_primaryType)) == %@", firstType.rawValue),
                    NSPredicate(format: "\(#keyPath(PokemonForm.z_secondaryType)) == %@", secondType.rawValue)
                ]),
                NSCompoundPredicate(andPredicateWithSubpredicates: [
                    NSPredicate(format: "\(#keyPath(PokemonForm.z_primaryType)) == %@", secondType.rawValue),
                    NSPredicate(format: "\(#keyPath(PokemonForm.z_secondaryType)) == %@", firstType.rawValue)
                ])
            ])
        ])
        return makeFetchRequest(with: predicate)
    }

    static func allFetchRequest(for game: Game) -> NSFetchRequest<PokemonForm> {
        let predicate = NSPredicate(format: "\(#keyPath(PokemonForm.i_gameIndex)) == %d", game.index)
        let request = makeFetchRequest(with: predicate)
        request.fetchBatchSize = 0
        return request
    }

    private static func makeFetchRequest(with predicate: NSPredicate) -> NSFetchRequest<PokemonForm> {
        let request: NSFetchRequest<PokemonForm> = PokemonForm.fetchRequest()
        request.fetchBatchSize = DatabaseConstants.fetchBatchSize
        request.predicate = predicate
        request.relationshipKeyPathsForPrefetching = [
            #keyPath(PokemonForm.z_pokemon),
            #keyPath(PokemonForm.z_evolutions)
        ]
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(PokemonForm.i_pokemonIndex), ascending: true),
            NSSortDescriptor(key: #keyPath(PokemonForm.i_formIndex), ascending: true)
        ]
        return request
    }

}

// MARK: - CanonicallyNamed
extension PokemonForm: CanonicallyNamed {

    var canonicalName: String { pokemon.canonicalName }

}

//// MARK: - Identifiable
//extension PokemonForm: Identifiable {
//
//    public var id: String { "\(index) \(formIndex) \(game)" }
//
//}

// MARK: - Computed Properties
public extension PokemonForm {

    var isMainForm: Bool { formIndex == 0 }

    var hasAbilities: Bool { primaryAbility != nil || secondaryAbility != nil || hiddenAbility != nil }

}

// MARK: - Values
public extension PokemonForm {

    var baseExperienceYield: Int {
        get { Int(z_baseExperienceYield) }
        set { z_baseExperienceYield = Int64(newValue) }
    }
    var baseFriendship: Int {
        get { Int(z_baseFriendship) }
        set { z_baseFriendship = Int64(newValue) }
    }
    var color: PokemonColor {
        get { PokemonColor(rawValue: z_color!)! }
        set { z_color = newValue.rawValue }
    }
    var familyName: String {
        get { z_familyName! }
        set { z_familyName = newValue }
    }
    var formIndex: Int {
        get { Int(z_formIndex) }
        set { z_formIndex = Int64(newValue); i_formIndex = Int32(newValue) }
    }
    var game: Game {
        get { Game(rawValue: z_game!)! }
        set { z_game = newValue.rawValue; i_gameIndex = Int32(newValue.index) }
    }
    var heightInMeters: Double {
        get { z_heightInMeters }
        set { z_heightInMeters = newValue }
    }
    var index: Int {
        get { Int(z_index) }
        set { z_index = Int64(newValue) }
    }
    var name: String {
        get { z_name! }
        set { z_name = newValue }
    }
    var pokedexEntry: String {
        get { z_pokedexEntry! }
        set { z_pokedexEntry = newValue }
    }
    var pokemonIndex: Int {
        get { Int(i_pokemonIndex) }
        set { i_pokemonIndex = Int32(newValue) }
    }
    var primaryType: PokemonType {
        get { PokemonType(rawValue: z_primaryType!)! }
        set { z_primaryType = newValue.rawValue }
    }
    var secondaryType: PokemonType? {
        get {
            guard let z_secondaryType = z_secondaryType else { return nil }
            return PokemonType(rawValue: z_secondaryType)
        }
        set { z_secondaryType = newValue?.rawValue }
    }
    var species: String {
        get { z_species! }
        set { z_species = newValue }
    }
    var weightInKilograms: Double {
        get { z_weightInKilograms }
        set { z_weightInKilograms = newValue }
    }

    var baseStats: Stats {
        get { z_baseStats! }
        set { z_baseStats = newValue }
    }
    var evolutions: [Evolution]? {
        get {
            (z_evolutions?.allObjects as? [Evolution])?.sorted {
                if $0.from.pokemon.index == $1.from.pokemon.index {
                    if $0.from.formIndex == $1.from.formIndex {
                        if $0.to.pokemon.index == $1.to.pokemon.index {
                            return $0.to.formIndex < $1.to.formIndex
                        } else {
                            return $0.to.pokemon.index < $1.to.pokemon.index
                        }
                    } else {
                        return $0.from.formIndex < $1.from.formIndex
                    }
                } else {
                    return $0.from.pokemon.index < $1.from.pokemon.index
                }
            }
        }
        set {
            guard let newValue = newValue else {
                z_evolutions = nil
                return
            }
            z_evolutions = NSSet(array: newValue) }
    }
    var evYield: Stats {
        get { z_evYield! }
        set { z_evYield = newValue }
    }
    var hiddenAbility: Ability? {
        get { z_hiddenAbility }
        set { z_hiddenAbility = newValue; i_hiddenAbilityIndex = Int32(newValue?.index ?? -1) }
    }
    var pokemon: Pokemon {
        get { z_pokemon! }
        set { z_pokemon = newValue }
    }
    var primaryAbility: Ability? {
        get { z_primaryAbility }
        set { z_primaryAbility = newValue; i_primaryAbilityIndex = Int32(newValue?.index ?? -1) }
    }
    var secondaryAbility: Ability? {
        get { z_secondaryAbility }
        set { z_secondaryAbility = newValue; i_secondaryAbilityIndex = Int32(newValue?.index ?? -1) }
    }

}
