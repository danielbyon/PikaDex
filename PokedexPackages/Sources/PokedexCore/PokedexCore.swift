//
//  PokedexCore.swift
//  
//
//  Created by Daniel Byon on 9/19/22.
//

@_exported import Foundation

import CoreData

extension Bundle {

    public static var pokedexCore: Bundle { .module }

}

private final class PokedexCoreMarker { }

public let pokedexDatabaseURL = Bundle.module.url(forResource: "Pokedex", withExtension: "sqlite")!

extension NSPersistentContainer {

    public static let pokedexContainer: NSPersistentContainer = {
        let modelURL = Bundle.module.url(forResource: "Pokedex", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!
        let container = NSPersistentContainer(name: "Pokedex", managedObjectModel: model)
        let url = Bundle.module.url(forResource: "Pokedex", withExtension: "sqlite")!
        let storeDescription = NSPersistentStoreDescription(url: url)
        storeDescription.isReadOnly = true
        container.persistentStoreDescriptions = [storeDescription]

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                debugPrint("Unresolved error \(error)")
                fatalError(error.localizedDescription)
            }
        })
        return container
    }()

    public static let userDataContainer: NSPersistentContainer = {
        let modelURL = Bundle.module.url(forResource: "UserData", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!
        let container = NSPersistentContainer(name: "UserData", managedObjectModel: model)

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                debugPrint("Unresolved error \(error)")
                fatalError(error.localizedDescription)
            }
        })
        return container
    }()

}
