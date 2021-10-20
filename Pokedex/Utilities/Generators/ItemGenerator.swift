//
//  ItemGenerator.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/26/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

extension Item {

    static func generateAntidote() -> Item {
        generate(withName: "Antidote", game: .sword)
    }

    static func generateRawstBerry() -> Item {
        generate(withName: "Rawst Berry", game: .ruby)
    }

    static func generate(withName name: String, game: Game) -> Item {
        let moc = Dependencies.container.viewContext
        let fetchRequest = Item.fetchRequest(forName: name, game: game)
        let item = try! moc.fetch(fetchRequest).first!
        return item
    }

    static func fetch(withName name: String, game: Game) -> Item? {
        let moc = Dependencies.container.viewContext
        let fetchRequest = Item.fetchRequest(forName: name, game: game)
        let item = try? moc.fetch(fetchRequest).first
        return item
    }

}
