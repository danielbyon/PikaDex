//
//  PokemonGenerator.swift
//  Pokedex
//
//  Created by Daniel Byon on 1/16/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI
import CoreData

extension StoredPokemon {

    private static var cache: [CacheKey: StoredPokemon] = [:]

    static func generateCharizard(game: Game = .letsGoPikachu) -> StoredPokemon {
        generate(withName: "Charizard", game: game)
    }

    static func generateAlcremie(game: Game = .sword) -> StoredPokemon {
        generate(withName: "Alcremie", game: game)
    }

    static func generate(withName name: String, game: Game) -> StoredPokemon {
        let cacheKey = CacheKey(name: name, game: game)
        if let cachedPokemon = cache[cacheKey] {
            return cachedPokemon
        }
        
        let moc = Dependencies.container.viewContext
        let fetchRequest = StoredPokemon.fetchRequest(forName: name, game: game)
        let pokemon = try! moc.fetch(fetchRequest).first!
        cache[cacheKey] = pokemon
        return pokemon
    }

}

private struct CacheKey: Hashable {

    let name: String
    let game: Game

}
