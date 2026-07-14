//
//  DatabaseValidator.swift
//  DatabaseLoader
//
//  Created by Daniel Byon on 12/3/22.
//  Copyright © 2022 Daniel Byon. All rights reserved.
//

import CoreData
import Foundation
import PokedexCore

final class Validator {

    private let container: NSPersistentContainer

    private var context: NSManagedObjectContext { container.viewContext }

    init(container: NSPersistentContainer) {
        self.container = container
    }

    func validate() {
        // Global objects
        validateAbilities()
        validateLocationMaps()
        validateStats()

        // Game-specific objects
        for game in Game.allDatasets {
            validateEvolutions(game: game)
            validateItems(game: game)
            validateLearnsetEntries(game: game)
            validateLocations(game: game)
            validateLocationPokemon(game: game)
            validateMachines(game: game)
            validateMoves(game: game)
            validatePokedexNumbers(game: game)
            validatePokemon(game: game)
            validatePokemonForms(game: game)
        }

        print("Finished validating!")
    }

    // MARK: Global Objects

    private func validateAbilities() {
        print("Validating Abilities")
        let fetchRequest: NSFetchRequest<StoredAbility> = StoredAbility.fetchRequest()
        fetchRequest.predicate = NSPredicate(value: true)
        let abilities = try! context.fetch(fetchRequest)

        for ability in abilities {
            let _ = ability.bulbapediaURL
            let _ = ability.pokemonDBURL
            let _ = ability.generationIntroduced
            let _ = ability.name
            let _ = Game.allDatasets.compactMap { ability.resolvedDescription(forGame: $0) }.first!
        }
    }

    private func validateLocationMaps() {
        print("Validating LocationMaps")
        let fetchRequest: NSFetchRequest<StoredLocationMap> = StoredLocationMap.fetchRequest()
        fetchRequest.predicate = NSPredicate(value: true)
        let locationMaps = try! context.fetch(fetchRequest)

        for locationMap in locationMaps {
            let _ = locationMap.areaName
            let _ = locationMap.filename
            let _ = locationMap.location
        }
    }

    private func validateStats() {
        print("Validating Stats")
        let fetchRequest: NSFetchRequest<StoredStats> = StoredStats.fetchRequest()
        fetchRequest.predicate = NSPredicate(value: true)
        let stats = try! context.fetch(fetchRequest)

        for stat in stats {
            let _ = stat.attack
            let _ = stat.defense
            let _ = stat.hp
            let _ = stat.specialAttack
            let _ = stat.specialDefense
            let _ = stat.speed
        }
    }

    // MARK: Game-specific Objects

    private func validateEvolutions(game: Game) {
        print("Validating Evolutions for \(game)")
        let fetchRequest: NSFetchRequest<StoredEvolution> = StoredEvolution.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(#keyPath(StoredEvolution.z_game)) == %@", game.rawValue)
        let evolutions = try! context.fetch(fetchRequest)

        for evolution in evolutions {
            let _ = evolution.familyName
            let _ = evolution.game
            let _ = evolution.method
            let _ = evolution.condition
            let _ = evolution.condition2
            let _ = evolution.from
            let _ = evolution.to
        }
    }

    private func validateItems(game: Game) {
        print("Validating Items for \(game)")
        let fetchRequest: NSFetchRequest<StoredItem> = StoredItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(#keyPath(StoredItem.z_game)) == %@", game.rawValue)
        let items = try! context.fetch(fetchRequest)

        for item in items {
            let _ = item.bulbapediaURL
            let _ = item.game
            let _ = item.generationIntroduced
            let _ = item.imageName
            let _ = item.itemDescription
            let _ = item.name
            let _ = item.pokemonDBURL
            assert(item.game.databaseIndex == item.i_gameIndex)

            if let bag = item.bagInfo {
                let _ = bag.itemDescription
                let _ = bag.pocket
                let _ = bag.item
            }

            if let berry = item.berryInfo {
                let _ = berry.firmness
                let _ = berry.itemDescription
                let _ = berry.item
            }
        }
    }

    private func validateLearnsetEntries(game: Game) {
        print("Validating LearnsetEntries for \(game)")
        let fetchRequest: NSFetchRequest<StoredLearnsetEntry> = StoredLearnsetEntry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(#keyPath(StoredLearnsetEntry.z_game)) == %@", game.rawValue)
        let learnsetEntries = try! context.fetch(fetchRequest)

        for learnsetEntry in learnsetEntries {
            let _ = learnsetEntry.game
            let _ = learnsetEntry.learnsetType
            let _ = learnsetEntry.level
            let _ = learnsetEntry.fathers
            let _ = learnsetEntry.form
            let _ = learnsetEntry.machine
            let _ = learnsetEntry.move
        }
    }

    private func validateLocations(game: Game) {
        print("Validating Locations for \(game)")
        let fetchRequest: NSFetchRequest<StoredLocation> = StoredLocation.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(#keyPath(StoredLocation.z_game)) == %@", game.rawValue)
        let locations = try! context.fetch(fetchRequest)

        for location in locations {
            let _ = location.bulbapediaURL
            let _ = location.canonicalName
            let _ = location.game
            let _ = location.name
            let _ = location.pokemonDBURL
            let _ = location.region
            let _ = location.maps
        }
    }

    private func validateLocationPokemon(game: Game) {
        print("Validating LocationPokemon for \(game)")
        let fetchRequest: NSFetchRequest<StoredLocationPokemon> = StoredLocationPokemon.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(#keyPath(StoredLocationPokemon.z_game)) == %@", game.rawValue)
        let locationPokemons = try! context.fetch(fetchRequest)

        for locationPokemon in locationPokemons {
            let _ = locationPokemon.detail
            let _ = locationPokemon.area
            let _ = locationPokemon.captureMethod
            let _ = locationPokemon.encounterCondition
            let _ = locationPokemon.encounterRate
            let _ = locationPokemon.game
            let _ = locationPokemon.levelHigh
            let _ = locationPokemon.levelLow
            let _ = locationPokemon.timeOfDay
            let _ = locationPokemon.location
            let _ = locationPokemon.pokemon
        }
    }

    private func validateMachines(game: Game) {
        print("Validating Machines for \(game)")
        let fetchRequest: NSFetchRequest<StoredMachine> = StoredMachine.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(#keyPath(StoredMachine.z_game)) == %@", game.rawValue)
        let machines = try! context.fetch(fetchRequest)

        for machine in machines {
            let _ = machine.game
            let _ = machine.number
            let _ = machine.type
            let _ = machine.move
            assert(machine.game.databaseIndex == machine.i_gameIndex)
        }
    }

    private func validateMoves(game: Game) {
        print("Validating Moves for \(game)")
        let fetchRequest: NSFetchRequest<StoredMove> = StoredMove.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(#keyPath(StoredMove.z_game)) == %@", game.rawValue)
        let moves = try! context.fetch(fetchRequest)

        for move in moves {
            let _ = move.accuracy
            let _ = move.bulbapediaURL
            let _ = move.canonicalName
            let _ = move.category
            let _ = move.game
            let _ = move.generationIntroduced
            let _ = move.index
            let _ = move.maxPP
            let _ = move.moveDescription
            let _ = move.name
            let _ = move.pokemonDBURL
            let _ = move.power
            let _ = move.pp
            let _ = move.priority
            let _ = move.targetAlly1
            let _ = move.targetAlly2
            let _ = move.targetDescription
            let _ = move.targetEnemy1
            let _ = move.targetEnemy2
            let _ = move.targetEnemy3
            let _ = move.targetSelf
            let _ = move.type
            assert(move.game.databaseIndex == move.i_gameIndex)
        }
    }

    private func validatePokedexNumbers(game: Game) {
        print("Validating PokedexNumbers for \(game)")
        let fetchRequest: NSFetchRequest<StoredPokedexNumbers> = StoredPokedexNumbers.fetchRequest()
        fetchRequest.predicate = NSPredicate(value: true)
        let pokedexNumbers = try! context.fetch(fetchRequest)

        for pokedexNumber in pokedexNumbers {
            let _ = pokedexNumber.pokemon
        }
    }

    private func validatePokemon(game: Game) {
        print("Validating Pokemon for \(game)")
        let fetchRequest: NSFetchRequest<StoredPokemon> = StoredPokemon.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(#keyPath(StoredPokemon.z_game)) == %@", game.rawValue)
        let pokemons = try! context.fetch(fetchRequest)

        if case .national = game {
            assert(!pokemons.isEmpty)
        }

        for pokemon in pokemons {
            let _ = pokemon.bulbapediaURL
            let _ = pokemon.canonicalName
            let _ = pokemon.catchRate
            let _ = pokemon.eggGroups
            let _ = pokemon.game
            let _ = pokemon.generationIntroduced
            let _ = pokemon.index
            let _ = pokemon.levelingRate
            let _ = pokemon.maleRatio
            let _ = pokemon.name
            let _ = pokemon.pokemonDBURL
            let _ = pokemon.forms
            let _ = pokemon.pokedexNumbers
            assert(pokemon.game.databaseIndex == pokemon.i_gameIndex)
        }
    }

    private func validatePokemonForms(game: Game) {
        print("Validating PokemonForms for \(game)")
        let fetchRequest: NSFetchRequest<StoredPokemonForm> = StoredPokemonForm.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(#keyPath(StoredPokemonForm.z_game)) == %@", game.rawValue)
        let pokemonForms = try! context.fetch(fetchRequest)

        if case .national = game {
            assert(!pokemonForms.isEmpty)
        }

        for pokemonForm in pokemonForms {
            let _ = pokemonForm.baseExperienceYield
            let _ = pokemonForm.baseFriendship
            let _ = pokemonForm.color
            let _ = pokemonForm.familyName
            let _ = pokemonForm.formIndex
            let _ = pokemonForm.game
            let _ = pokemonForm.heightInMeters
            let _ = pokemonForm.index
            let _ = pokemonForm.name
            let _ = pokemonForm.pokedexEntry
            let _ = pokemonForm.primaryType
            let _ = pokemonForm.secondaryType
            let _ = pokemonForm.species
            let _ = pokemonForm.weightInKilograms
            let _ = pokemonForm.baseStats
            let _ = pokemonForm.evolutions
            let _ = pokemonForm.evYield
            let _ = pokemonForm.hiddenAbility
            let _ = pokemonForm.pokemon
            let _ = pokemonForm.primaryAbility
            let _ = pokemonForm.secondaryAbility
        }
    }

}
