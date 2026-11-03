//
//  StoredItem+Extension.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/26/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Fetch Requests
public extension StoredItem {

    static func allFetchRequest(for game: Game) -> NSFetchRequest<StoredItem> {
        let request: NSFetchRequest<StoredItem> = StoredItem.fetchRequest()
        request.predicate = NSPredicate(format: "\(#keyPath(StoredItem.i_gameIndex)) == %d", game.databaseIndex)
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(StoredItem.i_nameIndex), ascending: true),
            NSSortDescriptor(key: #keyPath(StoredItem.z_generationIntroduced), ascending: true)
        ]
        commonConfigureRequest(request)
        return request
    }

    static func fetchRequest(forName name: String, game: Game) -> NSFetchRequest<StoredItem> {
        let request: NSFetchRequest<StoredItem> = StoredItem.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "\(#keyPath(StoredItem.z_name)) LIKE[cd] %@", name)
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(StoredItem.i_nameIndex), ascending: true)]
        commonConfigureRequest(request)
        return request
    }

    private static func commonConfigureRequest(_ request: NSFetchRequest<StoredItem>) {
        request.relationshipKeyPathsForPrefetching = [
            #keyPath(StoredItem.bagInfo),
            #keyPath(StoredItem.berryInfo)
        ]
        request.returnsObjectsAsFaults = false

    }

}

// MARK: - CanonicallyNamed
extension StoredItem: CanonicallyNamed {

    public var canonicalName: String { z_canonicalName ?? _missingString }

}

//// MARK: - Identifiable
//extension Item: Identifiable {
//
//    public var id: String { name + game.title }
//
//}

// MARK: - Values
public extension StoredItem {

    var bulbapediaURL: URL {
        get { URL(string: z_bulbapediaURL!)! }
        set { z_bulbapediaURL = newValue.absoluteString }
    }
    var game: Game {
        get { Game(rawValue: z_game!)! }
        set { z_game = newValue.rawValue }
    }
    var generationIntroduced: Generation {
        get { Generation(rawValue: Int(z_generationIntroduced))! }
        set { z_generationIntroduced = Int16(newValue.rawValue) }
    }
    var imageName: String {
        get { z_imageName! }
        set { z_imageName = newValue }
    }
    var itemDescription: String {
        get { z_itemDescription! }
        set { z_itemDescription = newValue }
    }
    var itemType: ItemType {
        get { ItemType(rawValue: Int(z_itemType))! }
        set { z_itemType = Int16(newValue.rawValue) }
    }
    var name: String {
        get { z_name! }
        set { z_name = newValue; z_canonicalName = newValue.normalizedForSearch }
    }
    var pokemonDBURL: URL? {
        get {
            guard let z_pokemonDBURL else { return nil }
            return URL(string: z_pokemonDBURL)
        }
        set { z_pokemonDBURL = newValue?.absoluteString }
    }

}
