//
//  LearnsetEntryFilter.swift
//  
//
//  Created by Daniel Byon on 10/13/22.
//

import CoreData
import Foundation

public struct LearnsetEntryFilter: SearchableFilter {

    public typealias ResultType = StoredLearnsetEntry

    public static var `default`: LearnsetEntryFilter {
        self.init(
            predicate: NSPredicate(value: false),
            sortDescriptors: [NSSortDescriptor(key: "z_game", ascending: true)]
        )
    }

    private let predicate: NSPredicate
    private let sortDescriptors: [NSSortDescriptor]
    public var query: String

    init(
        predicate: NSPredicate,
        sortDescriptors: [NSSortDescriptor],
        query: String = ""
    ) {
        self.predicate = predicate
        self.sortDescriptors = sortDescriptors
        self.query = query
    }

    public func makeFetchRequest(_ dataStore: DataStore) -> NSFetchRequest<StoredLearnsetEntry> {
        let fetchRequest: NSFetchRequest<StoredLearnsetEntry> = StoredLearnsetEntry.fetchRequest()
        var predicates = [predicate]
        if !query.isEmpty {
            predicates.append(NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_move.z_canonicalName)) CONTAINS[cd] %@", query))
        }
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.relationshipKeyPathsForPrefetching = [
            #keyPath(StoredLearnsetEntry.z_fathers),
            #keyPath(StoredLearnsetEntry.z_machine),
            #keyPath(StoredLearnsetEntry.z_machine.z_move),
            #keyPath(StoredLearnsetEntry.z_move),
            #keyPath(StoredLearnsetEntry.z_form),
            #keyPath(StoredLearnsetEntry.z_form.z_pokemon)
        ]
        return fetchRequest
    }

}

// MARK: Level
extension LearnsetEntryFilter {

    public static func level(
        pokemonForm: PokemonDetailForm,
        maxLevel: Int? = nil
    ) -> LearnsetEntryFilter {
        var subpredicates: [NSPredicate] = [
            NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_learnsetType)) == %@", LearnsetType.level.rawValue),
            NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_game)) == %@", pokemonForm.game.rawValue),
            NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_form.z_pokemon.z_index)) == %d", pokemonForm.index),
            NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_form.z_formIndex)) == %d", pokemonForm.formIndex)
        ]
        if let maxLevel {
            subpredicates.append(.init(format: "\(#keyPath(StoredLearnsetEntry.z_level)) <= %d", maxLevel))
        }
        return .init(
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates),
            sortDescriptors: [
                NSSortDescriptor(key: #keyPath(StoredLearnsetEntry.z_level), ascending: true),
                NSSortDescriptor(key: #keyPath(StoredLearnsetEntry.z_move.z_name), ascending: true)
            ]
        )
    }

    public static func level(move: Move) -> LearnsetEntryFilter {
        return .init(
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_learnsetType)) == %@", LearnsetType.level.rawValue),
                NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_game)) == %@", move.game.rawValue),
                NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_move.z_index)) == %d", move.index),
                NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_form.z_game)) == %@", move.game.rawValue)
            ]),
            sortDescriptors: [
                NSSortDescriptor(key: #keyPath(StoredLearnsetEntry.z_form.z_index), ascending: true),
                NSSortDescriptor(key: #keyPath(StoredLearnsetEntry.z_form.z_formIndex), ascending: true),
                NSSortDescriptor(key: #keyPath(StoredLearnsetEntry.z_level), ascending: true)
            ]
        )
    }

}

// MARK: Machine
extension LearnsetEntryFilter {

    public static func machine(pokemonForm: PokemonDetailForm) -> LearnsetEntryFilter {
        return .init(
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_learnsetType)) == %@", LearnsetType.machine.rawValue),
                NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_game)) == %@", pokemonForm.game.rawValue),
                NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_form.z_pokemon.z_index)) == %d", pokemonForm.index),
                NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_form.z_formIndex)) == %d", pokemonForm.formIndex),
            ]),
            sortDescriptors: [
                NSSortDescriptor(key: #keyPath(StoredLearnsetEntry.z_machine.z_type), ascending: true),
                NSSortDescriptor(key: #keyPath(StoredLearnsetEntry.z_machine.z_number), ascending: true)
            ]
        )
    }

    public static func machine(move: Move) -> LearnsetEntryFilter{
        return .init(
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_learnsetType)) == %@", LearnsetType.machine.rawValue),
                NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_game)) == %@", move.game.rawValue),
                NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_machine.z_move.z_index)) == %d", move.index),
                NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_form.z_game)) == %@", move.game.rawValue)
            ]),
            sortDescriptors: [
                NSSortDescriptor(key: #keyPath(StoredLearnsetEntry.z_form.z_index), ascending: true),
                NSSortDescriptor(key: #keyPath(StoredLearnsetEntry.z_form.z_formIndex), ascending: true),
                NSSortDescriptor(key: #keyPath(StoredLearnsetEntry.z_machine.z_number), ascending: true)
            ]
        )
    }

}

// MARK: Breeding
extension LearnsetEntryFilter {

    public static func breeding(pokemonForm: PokemonDetailForm) -> LearnsetEntryFilter {
        return .init(
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_learnsetType)) == %@", LearnsetType.breeding.rawValue),
                NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_game)) == %@", pokemonForm.game.rawValue),
                NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_form.z_pokemon.z_index)) == %d", pokemonForm.index),
                NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_form.z_formIndex)) == %d", pokemonForm.formIndex)
            ]),
            sortDescriptors: [
                NSSortDescriptor(key: #keyPath(StoredLearnsetEntry.z_move.z_name), ascending: true)
            ]
        )
    }

    public static func breeding(move: Move) -> LearnsetEntryFilter {
        return .init(
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_learnsetType)) == %@", LearnsetType.breeding.rawValue),
                NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_game)) == %@", move.game.rawValue),
                NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_move.z_index)) == %d", move.index),
                NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_form.z_game)) == %@", move.game.rawValue)
            ]),
            sortDescriptors: [
                NSSortDescriptor(key: #keyPath(StoredLearnsetEntry.z_form.z_index), ascending: true),
                NSSortDescriptor(key: #keyPath(StoredLearnsetEntry.z_form.z_formIndex), ascending: true)
            ]
        )
    }

}

// MARK: Tutoring
extension LearnsetEntryFilter {

    public static func tutoring(pokemonForm: PokemonDetailForm) -> LearnsetEntryFilter{
        return .init(
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_learnsetType)) == %@", LearnsetType.tutoring.rawValue),
                NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_game)) == %@", pokemonForm.game.rawValue),
                NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_form.z_pokemon.z_index)) == %d", pokemonForm.index),
                NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_form.z_formIndex)) == %d", pokemonForm.formIndex)
            ]),
            sortDescriptors: [
                NSSortDescriptor(key: #keyPath(StoredLearnsetEntry.z_move.z_name), ascending: true)
            ]
        )
    }

    public static func tutoring(move: Move) -> LearnsetEntryFilter {
        return .init(
            predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_learnsetType)) == %@", LearnsetType.tutoring.rawValue),
                NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_game)) == %@", move.game.rawValue),
                NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_move.z_index)) == %d", move.index),
                NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_form.z_game)) == %@", move.game.rawValue)
            ]),
            sortDescriptors: [
                NSSortDescriptor(key: #keyPath(StoredLearnsetEntry.z_form.z_index), ascending: true),
                NSSortDescriptor(key: #keyPath(StoredLearnsetEntry.z_form.z_formIndex), ascending: true)
            ]
        )
    }

}
