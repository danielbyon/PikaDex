//
//  AbilityPokemonFormFilter.swift
//  
//
//  Created by Daniel Byon on 9/28/22.
//

import CoreData
import Foundation

public struct AbilityPokemonFormFilter: QueryFilter {

    public typealias ResultType = StoredPokemonForm

    public static var `default`: AbilityPokemonFormFilter {
        self.init(
            ability: .init(
                generationIntroduced: 3,
                index: 1,
                name: "Blaze",
                descriptions: [:],
                bulbapediaURL: URL(string: "http://bulbapedia.bulbagarden.net/wiki/Blaze_(Ability)")!,
                pokemonDBURL: URL(string: "https://pokemondb.net/ability/blaze")!
            ),
            game: .national
        )
    }

    public var ability: Ability
    public var game: Game

    public func makeFetchRequest(_ dataStore: DataStore) -> NSFetchRequest<StoredPokemonForm> {
        let abilityIndex = Int16(ability.index)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "\(#keyPath(StoredPokemonForm.i_gameIndex)) == %d", game.index),
            NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate(format: "\(#keyPath(StoredPokemonForm.i_primaryAbilityIndex)) == %d", abilityIndex),
                NSPredicate(format: "\(#keyPath(StoredPokemonForm.i_secondaryAbilityIndex)) == %d", abilityIndex),
                NSPredicate(format: "\(#keyPath(StoredPokemonForm.i_hiddenAbilityIndex)) == %d", abilityIndex)
            ])
        ])
        let fetchRequest: NSFetchRequest<StoredPokemonForm> = StoredPokemonForm.fetchRequest()
        fetchRequest.fetchBatchSize = DatabaseConstants.fetchBatchSize
        fetchRequest.predicate = predicate
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

    public init(
        ability: Ability,
        game: Game
    ) {
        self.ability = ability
        self.game = game
    }

}
