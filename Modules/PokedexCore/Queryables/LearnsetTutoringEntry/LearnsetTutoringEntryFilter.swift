//
//  LearnsetTutoringEntryFilter.swift
//  
//
//  Created by Daniel Byon on 10/3/22.
//

import CoreData
import Foundation

public struct LearnsetTutoringEntryFilter: QueryFilter {

    public typealias ResultType = StoredLearnsetEntry

    public static var `default`: LearnsetTutoringEntryFilter {
        .init(
            predicate: NSPredicate.init(value: false),
            sortDescriptors: [
                NSSortDescriptor(key: #keyPath(StoredLearnsetEntry.z_move.z_name), ascending: true)
            ]
        )
    }

    private let predicate: NSPredicate
    private let sortDescriptors: [NSSortDescriptor]

    public init(pokemonForm: PokemonDetailForm) {
        self.init(
            predicate: NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_form.z_pokemon.z_index)) == %d && \(#keyPath(StoredLearnsetEntry.z_form.z_formIndex)) == %d", pokemonForm.index, pokemonForm.formIndex),
            sortDescriptors: [
                NSSortDescriptor(key: #keyPath(StoredLearnsetEntry.z_move.z_name), ascending: true)
            ]
        )
    }

    public init(move: Move) {
        self.init(
            predicate: NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_move.z_index)) == %d && \(#keyPath(StoredLearnsetEntry.z_form.z_game)) == %@", move.index, move.game.rawValue),
            sortDescriptors: [
                NSSortDescriptor(key: #keyPath(StoredLearnsetEntry.z_form.z_index), ascending: true),
                NSSortDescriptor(key: #keyPath(StoredLearnsetEntry.z_form.z_formIndex), ascending: true)
            ]
        )
    }

    init(
        predicate: NSPredicate,
        sortDescriptors: [NSSortDescriptor]
    ) {
        self.predicate = predicate
        self.sortDescriptors = sortDescriptors
    }

    public func makeFetchRequest() -> NSFetchRequest<StoredLearnsetEntry> {
        let fetchRequest: NSFetchRequest<StoredLearnsetEntry> = StoredLearnsetEntry.fetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.relationshipKeyPathsForPrefetching = [
            #keyPath(StoredLearnsetEntry.z_form),
            #keyPath(StoredLearnsetEntry.z_form.z_pokemon),
            #keyPath(StoredLearnsetEntry.z_move)
        ]
        return fetchRequest
    }

}
