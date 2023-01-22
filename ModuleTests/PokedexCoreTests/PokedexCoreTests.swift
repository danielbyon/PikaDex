//
//  PokedexCoreTests.swift
//  
//
//  Created by Daniel Byon on 9/20/22.
//

import CoreData
import XCTest

@testable import PokedexCore

final class PokedexCoreTests: XCTestCase {

    func testExample() throws {
        XCTAssertNotNil(Bundle.pokedexCore.url(forResource: "Pokedex", withExtension: "momd"))
        XCTAssertNotNil(Bundle.pokedexCore.url(forResource: "Pokedex", withExtension: "sqlite"))
        _ = NSPersistentContainer.pokedexContainer
    }

}
