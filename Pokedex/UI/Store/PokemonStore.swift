//
//  PokemonStore.swift
//  Pokedex
//
//  Created by Daniel Byon on 1/16/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI
import CoreData

extension Pokemon {

    static func generateCharizard(game: Game = .letsGoPikachu) -> Pokemon {
        generate(withName: "Charizard", game: game)
    }

    static func generateAlcremie(game: Game = .sword) -> Pokemon {
        generate(withName: "Alcremie", game: game)
    }

    static func generate(withName name: String, game: Game) -> Pokemon {
        let moc = Dependencies.container.viewContext
        let fetchRequest = Pokemon.fetchRequest(forName: name, game: game)
        let pokemon = try! moc.fetch(fetchRequest).first!
        return pokemon
    }

}
