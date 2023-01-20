//
//  StoredMove+CoreData.swift
//  Database
//
//  Created by Daniel Byon on 12/22/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Fetch Requests
public extension StoredMove {

    static func allFetchRequest(for game: Game) -> NSFetchRequest<StoredMove> {
        let predicate = allMovesPredicate(for: game)
        return makeFetchRequest(with: predicate, game: game)
    }

    static func allMovesPredicate(for game: Game) -> NSPredicate {
        return NSPredicate(format: "\(#keyPath(StoredMove.z_game)) == %@", game.rawValue)
    }

    static func allMovesSearchPredicate(for game: Game, searchText: String) -> NSPredicate {
        return NSPredicate(format: "\(#keyPath(StoredMove.z_game)) == %@ AND \(#keyPath(StoredMove.z_canonicalName)) CONTAINS[cd] %@", game.rawValue, searchText)
    }

    static func fetchRequest(forType type: PokemonType, game: Game) -> NSFetchRequest<StoredMove> {
        let predicate = NSPredicate(format: "\(#keyPath(StoredMove.z_game)) == %@ AND z_type == %@", game.rawValue, type.rawValue)
        return makeFetchRequest(with: predicate, game: game)
    }

    static func fetchRequest(withName name: String, game: Game) -> NSFetchRequest<StoredMove> {
        let predicate = NSPredicate(format: "\(#keyPath(StoredMove.z_game)) == %@ AND \(#keyPath(StoredMove.z_name)) == %@", game.rawValue, name)
        let request = makeFetchRequest(with: predicate, game: game)
        request.fetchLimit = 1
        return request
    }

    private static func makeFetchRequest(with predicate: NSPredicate, game: Game) -> NSFetchRequest<StoredMove> {
        let request: NSFetchRequest<StoredMove> = StoredMove.fetchRequest()
        request.predicate = predicate
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(StoredMove.z_name), ascending: true)]
        return request
    }

}

// MARK: - CanonicallyNamed
extension StoredMove: CanonicallyNamed {

    public var canonicalName: String { z_canonicalName ?? _missingString }

}

//// MARK: - Identifiable
//extension Move: Identifiable {
//
//    public var id: String { name }
//
//}

// MARK: - Properties
public extension StoredMove {

    var accuracy: Int? {
        get { (value(forKeyPath: #keyPath(StoredMove.z_accuracy)) as? Int64)?.toInt() }
        set { z_accuracy = newValue?.toInt64() ?? 0 }
    }
    var bulbapediaURL: URL {
        get { URL(string: z_bulbapediaURL!)! }
        set { z_bulbapediaURL = newValue.absoluteString }
    }
    var category: MoveCategory {
        get { MoveCategory(rawValue: z_category!)! }
        set { z_category = newValue.rawValue }
    }
    var game: Game {
        get { Game(rawValue: z_game!)! }
        set { z_game = newValue.rawValue; i_gameIndex = Int32(newValue.index) }
    }
    var generationIntroduced: Generation {
        get { Generation(rawValue: Int(z_generationIntroduced))! }
        set { z_generationIntroduced = Int64(newValue.rawValue) }
    }
    var index: Int {
        get { Int(z_index) }
        set { z_index = Int64(newValue) }
    }
    var maxPP: Int? {
        get { (value(forKeyPath: #keyPath(StoredMove.z_maxPP)) as? Int64)?.toInt() }
        set { z_maxPP = newValue?.toInt64() ?? 0 }
    }
    var moveDescription: String {
        get { z_moveDescription! }
        set { z_moveDescription = newValue }
    }
    var name: String {
        get { z_name! }
        set { z_name = newValue; z_canonicalName = newValue.normalizedForSearch }
    }
    var pokemonDBURL: URL {
        get { URL(string: z_pokemonDBURL!)! }
        set { z_pokemonDBURL = newValue.absoluteString }
    }
    var power: Int? {
        get { (value(forKeyPath: #keyPath(StoredMove.z_power)) as? Int64)?.toInt() }
        set { z_power = newValue?.toInt64() ?? 0 }
    }
    var pp: Int? {
        get { (value(forKeyPath: #keyPath(StoredMove.z_pp)) as? Int64)?.toInt() }
        set { z_pp = newValue?.toInt64() ?? 0 }
    }
    /// Unused
    var priority: Int {
        get { Int(z_priority) }
        set { z_priority = Int64(newValue) }
    }
    var targetAlly1: Bool {
        get { z_targetAlly1 }
        set { z_targetAlly1 = newValue }
    }
    var targetAlly2: Bool {
        get { z_targetAlly2 }
        set { z_targetAlly2 = newValue }
    }
    var targetDescription: String {
        get { z_targetDescription! }
        set { z_targetDescription = newValue }
    }
    var targetEnemy1: Bool {
        get { z_targetEnemy1 }
        set { z_targetEnemy1 = newValue }
    }
    var targetEnemy2: Bool {
        get { z_targetEnemy2 }
        set { z_targetEnemy2 = newValue }
    }
    var targetEnemy3: Bool {
        get { z_targetEnemy3 }
        set { z_targetEnemy3 = newValue }
    }
    var targetSelf: Bool {
        get { z_targetSelf }
        set { z_targetSelf = newValue }
    }
    var type: PokemonType {
        get { PokemonType(rawValue: z_type!)! }
        set { z_type = newValue.rawValue }
    }

}
