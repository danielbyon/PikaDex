//
//  MoveStore.swift
//  Pokedex
//
//  Created by Daniel Byon on 1/27/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI
import CoreData

extension Move {

    static func generateThunderShock() -> Move {
        generate(withName: "Thunder Shock", game: .sword)
    }

    static func generate(withName name: String, game: Game) -> Move {
        let moc = Dependencies.container.viewContext
        let fetchRequest = Move.fetchRequest(withName: name, game: game)
        let move = try! moc.fetch(fetchRequest).first!
        return move
    }

    static func fetch(withName name: String, game: Game) -> Move? {
        let moc = Dependencies.container.viewContext
        let fetchRequest = Move.fetchRequest(withName: name, game: game)
        let move = try? moc.fetch(fetchRequest).first
        return move
    }

}
