//
//  DatabaseTests.swift
//  DatabaseTests
//
//  Created by Daniel Byon on 12/18/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import XCTest
import CoreData
@testable import PikaDex

class DatabaseTests: XCTestCase {

    private var container: NSPersistentContainer!

    override func setUp() {
        let model = NSManagedObjectModel(contentsOf: Bundle.main.url(forResource: "Pokedex", withExtension: "momd")!)!
        container = NSPersistentContainer(name: "Pokedex", managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
        }

        let url = container.persistentStoreDescriptions.first!.url!
        try! container.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType, options: nil)

        container = NSPersistentContainer(name: "Pokedex", managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
        }
    }

    override func tearDown() {
        let url = container.persistentStoreDescriptions.first!.url!
        try! container.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType, options: nil)
    }

    func testCreation() {
        let moc = container.viewContext

        let pokemon = Pokemon(context: moc)
        pokemon.name = "Pikachu"
        pokemon.index = 25
        pokemon.forms = [PokemonForm(context: moc)]

        try! moc.save()
    }

}
