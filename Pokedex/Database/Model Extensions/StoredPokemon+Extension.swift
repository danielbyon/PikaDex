//
//  StoredPokemon+Extension.swift
//  Database
//
//  Created by Daniel Byon on 12/18/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Fetch Requests
public extension StoredPokemon {

    static func allFetchRequest(for game: Game, filter: Filter) -> NSFetchRequest<StoredPokemon> {
        let request: NSFetchRequest<StoredPokemon> = StoredPokemon.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "\(#keyPath(StoredPokemon.i_gameIndex)) == %d", game.index),
            filter.predicate
        ])
        request.relationshipKeyPathsForPrefetching = [
            #keyPath(StoredPokemon.z_pokedexNumbers),
            #keyPath(StoredPokemon.z_forms)
        ]
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = filter.sortDescriptors
        return request
    }

    static func fetchRequest(forName name: String, game: Game) -> NSFetchRequest<StoredPokemon> {
        let request: NSFetchRequest<StoredPokemon> = StoredPokemon.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "\(#keyPath(StoredPokemon.z_name)) LIKE[cd] %@ AND \(#keyPath(StoredPokemon.i_gameIndex)) == %d", name, game.index)
        request.relationshipKeyPathsForPrefetching = [
            #keyPath(StoredPokemon.z_pokedexNumbers),
            #keyPath(StoredPokemon.z_forms)
        ]
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(StoredPokemon.z_index), ascending: true)]
        return request
    }

    static func fetchRequest(forType type: PokemonType, game: Game) -> NSFetchRequest<StoredPokemon> {
        let request: NSFetchRequest<StoredPokemon> = StoredPokemon.fetchRequest()
        request.predicate = NSPredicate(format: "\(#keyPath(StoredPokemon.i_gameIndex)) == %d AND (ANY \(#keyPath(StoredPokemon.z_forms.z_primaryType)) == %@ OR ANY \(#keyPath(StoredPokemon.z_forms.z_secondaryType)) == %@)", game.index, type.rawValue, type.rawValue)
        request.relationshipKeyPathsForPrefetching = [
            #keyPath(StoredPokemon.z_pokedexNumbers),
            #keyPath(StoredPokemon.z_forms)
        ]
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(StoredPokemon.z_index), ascending: true)]
        return request
    }

    static func fetchRequest(for pokemon: StoredPokemon, game: Game) -> NSFetchRequest<StoredPokemon> {
        let request: NSFetchRequest<StoredPokemon> = StoredPokemon.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "self == %@ AND \(#keyPath(StoredPokemon.i_gameIndex)) == %d", pokemon.objectID, game.index)
        request.returnsObjectsAsFaults = false
        request.relationshipKeyPathsForPrefetching = [
            #keyPath(StoredPokemon.z_pokedexNumbers),
            #keyPath(StoredPokemon.z_forms),
            #keyPath(StoredPokemon.z_forms.z_baseStats),
            #keyPath(StoredPokemon.z_forms.z_evolutions),
            #keyPath(StoredPokemon.z_forms.z_evolutions.ability),
            #keyPath(StoredPokemon.z_forms.z_evolutions.item),
            #keyPath(StoredPokemon.z_forms.z_evolutions.move),
            #keyPath(StoredPokemon.z_forms.z_evolutions.pokemon),
            #keyPath(StoredPokemon.z_forms.z_evYield),
            #keyPath(StoredPokemon.z_forms.z_hiddenAbility),
            #keyPath(StoredPokemon.z_forms.z_primaryAbility),
            #keyPath(StoredPokemon.z_forms.z_secondaryAbility),
            #keyPath(StoredPokemon.z_locationPokemons),
            "z_locationPokemons.z_location"
        ]
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(StoredPokemon.z_index), ascending: true)]
        return request
    }

}

// MARK: - CanonicallyNamed
extension StoredPokemon: CanonicallyNamed {

    var canonicalName: String { z_canonicalName ?? _missingString }

}

//// MARK: - Identifiable
//extension Pokemon: Identifiable {
//
//    public var id: Int { index }
//
//}

// MARK: - Computed Properties
public extension StoredPokemon {

    var femaleRatio: Double? { maleRatio != nil ? 100.0 - maleRatio! : nil }

}

// MARK: - Values
public extension StoredPokemon {

    var catchRate: Int {
        get { Int(z_catchRate) }
        set { z_catchRate = Int64(newValue) }
    }
    var eggGroups: [EggGroup] {
        get { (z_eggGroups ?? _missingString).components(separatedBy: ",").compactMap { EggGroup(rawValue: $0) } }
        set { z_eggGroups = newValue.map { $0.rawValue }.joined(separator: ",") }
    }
    var game: Game {
        get { Game(rawValue: z_game!)! }
        set { z_game = newValue.rawValue; i_gameIndex = Int32(newValue.index) }
    }
    var generationIntroduced: Generation {
        get { Generation(rawValue: Int(z_generationIntroduced))! }
        set { z_generationIntroduced = Int32(newValue.rawValue) }
    }
    var index: Int {
        get { Int(z_index) }
        set { z_index = Int32(newValue) }
    }
    var levelingRate: LevelingRate {
        get { LevelingRate(rawValue: z_levelingRate!)! }
        set { z_levelingRate = newValue.rawValue }
    }
    var maleRatio: Double? {
        get { z_maleRatio?.doubleValue }
        set { z_maleRatio = newValue != nil ? NSNumber(value: newValue!) : nil }
    }
    var name: String {
        get { z_name! }
        set { z_name = newValue; z_canonicalName = newValue.normalizedForSearch }
    }

    var forms: [PokemonForm] {
        get { ((z_forms?.allObjects ?? []) as! [PokemonForm]).sorted { $0.formIndex < $1.formIndex } }
        set { z_forms = NSSet(array: newValue); z_formCount = Int16(newValue.count) }
    }
    var pokedexNumbers: PokedexNumbers {
        get { z_pokedexNumbers! }
        set { z_pokedexNumbers = newValue }
    }

}

public extension StoredPokemon {

    var defaultForm: PokemonForm { forms.first! }

    var hasAlternateForms: Bool { z_formCount > 1 }

}

private extension StoredPokemon.Filter {

    var predicate: NSPredicate {
        NSPredicate(format: "\(filterBy.keyPath) != -1")
    }

    var sortDescriptors: [NSSortDescriptor] {
        let ascending = sortOrder == .ascending
        switch sortBy {
        case .number:
            return [
                NSSortDescriptor(key: filterBy.keyPath, ascending: ascending)
            ]
        case .name:
            return [
                NSSortDescriptor(key: #keyPath(StoredPokemon.z_name), ascending: ascending)
            ]
        }
    }

}
