//
//  BattleAssistantViewModel.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/24/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import AppSupport

final class BattleAssistantViewModel: ObservableObject {

    @Published var pokemon: Pokemon? {
        didSet {
            pokemonName = pokemon?.name
            game = pokemon?.game
        }
    }

    @UserDefault(key: "battleassistant.level", defaultValue: 1) var level: Int {
        willSet {
            objectWillChange.send()
        }
    }

    @UserDefault(key: "battleassistant.pokemon", defaultValue: nil) private var pokemonName: String? {
        willSet {
            objectWillChange.send()
        }
    }

    @UserDefault(key: "battleassistant.game", defaultValue: nil) private var game: Game? {
        willSet {
            objectWillChange.send()
        }
    }

    init() {
        fetchPokemon()
    }

    private func fetchPokemon() {
        guard let pokemonName = pokemonName,
            let game = game else { return }
        guard game == Dependencies.appContext.currentGame else {
            debugPrint("Game for saved Battle Assistant Pokémon (\(pokemonName) - \(game)) doesn't match current game \(Dependencies.appContext.currentGame), clearing out old values")
            self.pokemonName = nil
            self.game = nil
            return
        }
        let moc = Dependencies.container.viewContext
        let request = Pokemon.fetchRequest(forName: pokemonName, game: game)
        do {
            let pokemon = try moc.fetch(request).first
            self.pokemon = pokemon
        } catch {
            debugPrint(error)
        }
    }

}
