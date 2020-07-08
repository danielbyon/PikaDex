//
//  Item+Extension.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/26/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

// MARK: - Fetch Requests
public extension Item {

    static func allFetchRequest(for game: Game) -> NSFetchRequest<Item> {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "\(#keyPath(Item.i_gameIndex)) == %d", game.index)
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(Item.i_nameIndex), ascending: true),
            NSSortDescriptor(key: #keyPath(Item.z_generationIntroduced), ascending: true)
        ]
        commonConfigureRequest(request)
        return request
    }

    static func fetchRequest(forName name: String, game: Game) -> NSFetchRequest<Item> {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "\(#keyPath(Item.z_name)) LIKE[cd] %@", name)
        request.sortDescriptors = [NSSortDescriptor(key: #keyPath(Item.i_nameIndex), ascending: true)]
        commonConfigureRequest(request)
        return request
    }

    private static func commonConfigureRequest(_ request: NSFetchRequest<Item>) {
        request.relationshipKeyPathsForPrefetching = [
            #keyPath(Item.bagInfo),
            #keyPath(Item.berryInfo)
        ]
        request.returnsObjectsAsFaults = false

    }

}

// MARK: - CanonicallyNamed
extension Item: CanonicallyNamed {

    var canonicalName: String { z_canonicalName ?? _missingString }

}

// MARK: - Identifiable
extension Item: Identifiable {

    public var id: String { name + game.title }

}

// MARK: - Values
public extension Item {

    var game: Game {
        get { Game(rawValue: z_game!)! }
        set { z_game = newValue.rawValue }
    }

    var generationIntroduced: Generation {
        get { Generation(rawValue: Int(z_generationIntroduced))! }
        set { z_generationIntroduced = Int32(newValue.rawValue) }
    }

    var imageName: String {
        get { z_imageName! }
        set { z_imageName = newValue }
    }

    var itemType: ItemType {
        get { ItemType(rawValue: Int(z_itemType))! }
        set { z_itemType = Int64(newValue.rawValue) }
    }

    var name: String {
        get { z_name! }
        set { z_name = newValue; z_canonicalName = newValue.normalizedForSearch }
    }

}
