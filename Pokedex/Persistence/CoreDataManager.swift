//
//  CoreDataManager.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/8/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData

final class CoreDataManager {

    private(set) var container: NSPersistentContainer?

    init() {
        let model = NSManagedObjectModel(contentsOf: Bundle.main.url(forResource: "Pokedex", withExtension: "momd")!.appendingPathComponent("Pokedex.mom"))!
        let container = NSPersistentContainer(name: "Pokedex", managedObjectModel: model)
        let url = Bundle.main.url(forResource: "Pokedex", withExtension: "sqlite")!
        let storeDescription = NSPersistentStoreDescription(url: url)
        storeDescription.isReadOnly = true
        container.persistentStoreDescriptions = [storeDescription]

        var capturedError: Error?
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            capturedError = error
            if let error = error as NSError? {
                debugPrint("Unresolved error \(error)")
            }
        })
        guard capturedError == nil else { return }
        self.container = container
    }

}
