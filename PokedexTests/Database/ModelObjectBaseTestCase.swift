//
//  ModelObjectBaseTestCase.swift
//  DatabaseTests
//
//  Created by Daniel Byon on 1/3/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import XCTest
import CoreData
@testable import PikaDex

class ModelObjectBaseTestCase: XCTestCase {

    private(set) var container: NSPersistentContainer!
    
    var context: NSManagedObjectContext { container.viewContext }
    
    override func setUp() {
        let model = NSManagedObjectModel(contentsOf: Bundle.main.url(forResource: "Pokedex", withExtension: "momd")!)!
        container = NSPersistentContainer(name: "Pokedex", managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
        }
        
        // Destroy the persistent store, in case the previous test run crashed
        let url = container.persistentStoreDescriptions.first!.url!
        try! container.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType, options: nil)
        
        // Re-create and reload the container after destroying
        container = NSPersistentContainer(name: "Pokedex", managedObjectModel: model)
        container.loadPersistentStores { _, error in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
        }
        
        
        // Reset context after each test
        addTeardownBlock {
            self.context.rollback()
        }
    }
    
    override func tearDown() {
        let url = container.persistentStoreDescriptions.first!.url!
        try! container.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType, options: nil)
    }
    
    // MARK: Helpers
    
    func validateInt(_ value: Int?) {
        XCTAssertNotEqual(value, _missingInt)
    }
    
    func validateInt16(_ value: Int16?) {
        XCTAssertNotEqual(value, _missingInt16)
    }
    
    func validateDouble(_ value: Double?) {
        XCTAssertNotEqual(value, _missingDouble)
    }
    
    func validateBool(_ value: Bool?) {
        XCTAssertNotEqual(value, false)
    }
    
    func validateString(_ value: String?) {
        XCTAssertNotEqual(value, _missingString)
    }
    
    func validateRelationshipObject(_ value: NSManagedObject?, expected: NSManagedObject?) {
        XCTAssertEqual(value, expected)
    }
    
    func validateRelationshipObjects(_ value: [NSManagedObject]?, expected: [NSManagedObject]?) {
        XCTAssertEqual(value, expected)
    }

}
