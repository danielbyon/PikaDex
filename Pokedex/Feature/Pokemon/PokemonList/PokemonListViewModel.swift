//
//  PokemonListViewModel.swift
//  
//
//  Created by Daniel Byon on 9/19/22.
//

import Combine
import Dependencies
import PokedexCore
import SwiftUI

/// Main-actor observable state for Pokémon list filtering and presentation.
@MainActor
final class PokemonListViewModel: ObservableObject {

    // MARK: Properties

    @Published var filter: PokemonFilter

    var game: Game {
        didSet {
            if game != oldValue {
                filter = Self.readSerializedFilter(for: game, userDefaults: userDefaults) ?? .default(for: game)
            }
        }
    }
    @Dependency(\.userDataDataStore) private var dataStore

    var pokedex: Pokedex { filter.pokedex }

    private let userDefaults: UserDefaults
    private var subscriptions: Set<AnyCancellable> = []

    // MARK: Init

    init(
        game: Game = .sword,
        userDefaults: UserDefaults = .standard
    ) {
        self.game = game
        self.userDefaults = userDefaults

        if let filter = Self.readSerializedFilter(for: game, userDefaults: userDefaults) {
            _filter = .init(initialValue: filter)
        } else {
            _filter = .init(initialValue: .default(for: game))
        }

        $filter
            .dropFirst()
            .sink { filter in
                Self.saveFilter(filter, userDefaults: userDefaults)
            }
            .store(in: &subscriptions)
    }

    // MARK: Functions

    func pokemonIsCaught(
        _ pokemon: Pokemon,
        caughtPokemons: some RandomAccessCollection<CaughtPokemon>
    ) -> Bool {
        return caughtPokemons.contains { $0.index == pokemon.index }
    }

    func markPokemonCaught(_ pokemon: Pokemon) {
        let caughtPokemon = CaughtPokemon(pokemon: pokemon)
        do {
            try dataStore.save(caughtPokemon)
        } catch {
            debugPrint(error)
        }
    }

    func markPokemonUncaught(_ pokemon: Pokemon) {
        let caughtPokemon = CaughtPokemon(pokemon: pokemon)
        do {
            try dataStore.remove(CaughtPokemon.self, filter: .init(caughtPokemon: caughtPokemon))
        } catch {
            debugPrint(error)
        }
    }

    // MARK: Private

    private static func filterKey(forGame game: Game) -> String {
        return "pokemonlistfilter.filter-\(game.rawValue)"
    }

    private static func readSerializedFilter(for game: Game, userDefaults: UserDefaults) -> PokemonFilter? {
        guard let data = userDefaults.data(forKey: filterKey(forGame: game)),
              let filter = try? JSONDecoder().decode(PokemonFilter.self, from: data),
              filter.game == game else {
            return nil
        }
        return filter
    }

    private static func writeSerializedFilter(_ filter: PokemonFilter, userDefaults: UserDefaults) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(filter)
            userDefaults.set(data, forKey: filterKey(forGame: filter.game))
        } catch {
            assertionFailure("Failed to serialize filter: \(error)")
        }
    }

    private static func saveFilter(_ filter: PokemonFilter, userDefaults: UserDefaults) {
        writeSerializedFilter(filter, userDefaults: userDefaults)
    }

}
