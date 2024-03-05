//
//  PokemonDetailFormFilter.swift
//  
//
//  Created by Daniel Byon on 9/28/22.
//

import CoreData
import Foundation

public struct PokemonDetailFormFilter: SearchableFilter {

    public typealias ResultType = StoredPokemonForm

    public static var `default`: PokemonDetailFormFilter {
        return .init(predicate: .init(value: false))
    }

    private let predicate: NSPredicate
    public var query: SearchQuery

    public init(
        predicate: NSPredicate,
        query: SearchQuery = .empty
    ) {
        self.predicate = predicate
        self.query = query
    }

    public func makeFetchRequest(_ dataStore: DataStore) -> NSFetchRequest<StoredPokemonForm> {
        let fetchRequest: NSFetchRequest<StoredPokemonForm> = StoredPokemonForm.fetchRequest()
        fetchRequest.fetchBatchSize = DatabaseConstants.fetchBatchSize
        var predicates = [predicate]

        if !query.isEmpty {
            switch query {
            case .contains(let string):
                predicates.append(.init(format: "\(#keyPath(StoredPokemonForm.z_pokemon.z_canonicalName)) CONTAINS %@", string.normalizedForSearch))
            case .exact(let string):
                predicates.append(.init(format: "\(#keyPath(StoredPokemonForm.z_pokemon.z_canonicalName)) == %@", string.normalizedForSearch))
            }
        }

        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.relationshipKeyPathsForPrefetching = [
            #keyPath(StoredPokemonForm.z_pokemon)
        ]
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(StoredPokemonForm.i_pokemonIndex), ascending: true),
            NSSortDescriptor(key: #keyPath(StoredPokemonForm.i_formIndex), ascending: true)
        ]
        return fetchRequest
    }

}

extension PokemonDetailFormFilter {

    public init(game: Game) {
        self.init(predicate: NSPredicate(format: "\(#keyPath(StoredPokemonForm.i_gameIndex)) == %d", game.index))
    }

    public init(ability: Ability, game: Game) {
        let abilityIndex = Int16(ability.index)
        self.init(
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "\(#keyPath(StoredPokemonForm.i_gameIndex)) == %d", game.index),
                NSCompoundPredicate(orPredicateWithSubpredicates: [
                    NSPredicate(format: "\(#keyPath(StoredPokemonForm.i_primaryAbilityIndex)) == %d", abilityIndex),
                    NSPredicate(format: "\(#keyPath(StoredPokemonForm.i_secondaryAbilityIndex)) == %d", abilityIndex),
                    NSPredicate(format: "\(#keyPath(StoredPokemonForm.i_hiddenAbilityIndex)) == %d", abilityIndex)
                ])
            ])
        )
    }

    public init(type: PokemonType, game: Game) {
        self.init(
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "\(#keyPath(StoredPokemonForm.z_game)) == %@", game.rawValue),
                NSCompoundPredicate(orPredicateWithSubpredicates: [
                    NSPredicate(format: "\(#keyPath(StoredPokemonForm.z_primaryType)) == %@", type.rawValue),
                    NSPredicate(format: "\(#keyPath(StoredPokemonForm.z_secondaryType)) == %@", type.rawValue)
                ])
            ])
        )
    }

    public init(
        firstType: PokemonType,
        secondType: PokemonType,
        game: Game
    ) {
        self.init(
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "\(#keyPath(StoredPokemonForm.z_game)) == %@", game.rawValue),
                NSPredicate(format: "\(#keyPath(StoredPokemonForm.z_primaryType)) == %@", firstType.rawValue),
                NSPredicate(format: "\(#keyPath(StoredPokemonForm.z_secondaryType)) == %@", secondType.rawValue)
            ])
        )
    }

    public init(
        pokemonName: String,
        formIndex: Int,
        game: Game
    ) {
        self.init(
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "\(#keyPath(StoredPokemonForm.i_gameIndex)) == %d", game.index),
                NSPredicate(format: "\(#keyPath(StoredPokemonForm.z_pokemon.z_name)) == %@", pokemonName),
                NSPredicate(format: "\(#keyPath(StoredPokemonForm.i_formIndex)) == %d", formIndex)
            ])
        )
    }

    public init(
        pokemonName: String,
        formName: String,
        game: Game
    ) {
        self.init(
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "\(#keyPath(StoredPokemonForm.i_gameIndex)) == %d", game.index),
                NSPredicate(format: "\(#keyPath(StoredPokemonForm.z_pokemon.z_name)) == %@", pokemonName),
                NSPredicate(format: "\(#keyPath(StoredPokemonForm.z_name)) == %@", formName)
            ])
        )
    }

}
