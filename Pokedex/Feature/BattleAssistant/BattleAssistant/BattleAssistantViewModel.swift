//
//  BattleAssistantViewModel.swift
//  
//
//  Created by Daniel Byon on 10/23/22.
//

import CoreData
import PokedexCore
import SwiftUI

final class BattleAssistantViewModel: ObservableObject {

    @Published var pokemonForm: PokemonDetailForm? {
        didSet {
            storedPokemonName = pokemonForm?.pokemonName
            storedPokemonFormIndex = pokemonForm?.formIndex ?? 0
            storedGame = pokemonForm?.game
        }
    }

    @Published var game: Game = .national

    @AppStorage("battleassistant.level", store: .appGroup)
    var level: Double = 100.0 {
        willSet {
            objectWillChange.send()
        }
    }

    @AppStorage("battleassistant.pokemon", store: .appGroup)
    private var storedPokemonName: String? {
        willSet {
            objectWillChange.send()
        }
    }

    @AppStorage("battleassistant.pokemonFormIndex", store: .appGroup)
    private var storedPokemonFormIndex: Int = 0 {
        willSet {
            objectWillChange.send()
        }
    }

    @AppStorage("battleassistant.game", store: .appGroup)
    private var storedGame: Game? {
        willSet {
            objectWillChange.send()
        }
    }

    init() {

    }

    func onAppear(game: Game) {
        self.game = game

        guard let storedPokemonName,
              let storedGame else { return }

        guard storedGame == game else {
            debugPrint("Game for saved Battle Assistant Pokémon (\(storedPokemonName)/\(storedPokemonFormIndex) - \(storedGame)) doesn't match current game \(game), clearing out old values")
            self.storedPokemonName = nil
            self.storedGame = nil
            return
        }

        fetchPokemon(
            pokemonName: storedPokemonName,
            formIndex: storedPokemonFormIndex,
            game: storedGame
        )
    }

    private func fetchPokemon(pokemonName: String, formIndex: Int, game: Game) {
        let filter = PokemonDetailFormFilter(
            pokemonName: pokemonName,
            formIndex: formIndex,
            game: game
        )
        let container = NSPersistentContainer.pokedexContainer
        let request = filter.makeFetchRequest(DataStore(container: container))
        do {
            guard let storedPokemonForm = try container.viewContext.fetch(request).first else { return }
            self.pokemonForm = .init(result: storedPokemonForm)
        } catch {
            debugPrint(error)
        }
    }

}
