//
//  main.swift
//  DatabaseLoader
//
//  Created by Daniel Byon on 1/2/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData
import PokedexCore

// MARK: - Global Variables
let container = Helper.loadContainer(removeExistingContainer: true)
let moc = container.viewContext
var allPokemon: [Int: [Game: StoredPokemon]] = [:]
var allPokemonByName: [String: [Game: StoredPokemon]] = [:]
var pokemonNameIndices: [String: Int] = [:]
var allAbilities: [String: StoredAbility] = [:]
var allItems: [String: [Game: StoredItem]] = [:]
var allMoves: [String: [Game: StoredMove]] = [:]
var allTMs: [Game: [Int: StoredMachine]] = [:]
var allHMs: [Game: [Int: StoredMachine]] = [:]
var allTRs: [Game: [Int: StoredMachine]] = [:]
var allLocations: [Game: [String: StoredLocation]] = [:]


// MARK: - Global Helpers
let validNameCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "♂♀"))
func sanitizedName(_ name: String) -> String {
    String(name.lowercased().unicodeScalars.filter { validNameCharacters.contains($0) })
}
func sanitizedItemName(_ name: String) -> String {
    sanitizedName(name)
}
func sanitizedMoveName(_ moveName: String) -> String {
    var sanitized = sanitizedName(moveName)
    if sanitized == "faintattack" {
        sanitized = "feintattack"
    } else if sanitized == "hijumpkick" {
        sanitized = "highjumpkick"
    } else if sanitized == "smellingsalt" {
        sanitized = "smellingsalts"
    } else if sanitized == "vicegrip" {
        sanitized = "visegrip"
    }
    return sanitized
}

func getPokemon(forName name: String, game: Game) -> StoredPokemon {
    var name = name
    if name == "Boltound" {
        name = "Boltund"
    } else if name == "Shifty" {
        name = "Shiftry"
    } else if name == "Grimmsanrl" {
        name = "Grimmsnarl"
    } else if name == "Lycnaroc" {
        name = "Lycanroc"
    } else if name == "Pinchurchin" {
        name = "Pincurchin"
    } else if name == "NidoranM" {
        name = "Nidoran\u{2642}"
    } else if name == "Mamectric" {
        name = "Manectric"
    } else if name == "Doduro" {
        name = "Doduo"
    }
    return allPokemonByName[sanitizedName(name)]![game]!
}
func getItem(forName name: String, game: Game) -> StoredItem? {
    allItems[sanitizedItemName(name)]![game]
}
func getMove(forName name: String, game: Game) -> StoredMove? {
    allMoves[sanitizedMoveName(name)]![game]
}
func getAbility(forName name: String) -> StoredAbility {
    allAbilities[sanitizedName(name)]!
}
func getLocation(forName locationName: String, region: String, game: Game) -> StoredLocation? {
    allLocations[game]?[locationName + region]
}
func setLocation(_ location: StoredLocation, forName locationName: String, region: String, game: Game) {
    var gameLocations = allLocations[game] ?? [:]
    gameLocations[locationName + region] = location
    allLocations[game] = gameLocations
}
func getMachine(for machine: StoredMachine, game: Game) -> StoredMachine? {
    switch machine.type {
    case .tm:
        return allTMs[game]?[machine.number]
    case .hm:
        return allHMs[game]?[machine.number]
    case .tr:
        return allTRs[game]?[machine.number]
    }
}

// MARK: - Main
print("Pokedex Database Loader")
print()
let start = Date()


// MARK: - Abilities
print("--- Abilities ---")
let abilitiesExternalLinksDict = Helper.loadExternalLinksTSV(from: "Research/AbilityExternalLinks.tsv")

func abilityDescriptionKeyCandidates(for game: Game) -> [String] {
    var candidates = [game]
    if game == .omegaRuby {
        candidates.append(.ruby)
    } else if game == .alphaSapphire {
        candidates.append(.sapphire)
    }

    let keys = candidates.map(Game.pokemonDBKey)
    return keys
}

var abilityIndex = 0
for (abilityName, dict) in Helper.loadJSON(from: "Data/Abilities.json") as! [String: [String: String]] {
    let ability = StoredAbility(context: moc)
    allAbilities[sanitizedName(abilityName)] = ability
    ability.name = abilityName
    ability.index = abilityIndex; abilityIndex += 1

    let externalLinks = abilitiesExternalLinksDict[sanitizedName(abilityName)]!
    ability.bulbapediaURL = Helper.sanitizedURL(from: externalLinks["bulbapediaURL"]!)!
    ability.pokemonDBURL = Helper.sanitizedURL(from: externalLinks["pokemonDBURL"]!)!

    for (gameKey, description) in dict {
        let game = Game(pokemonDBKey: gameKey)
        ability.setDescription(description, forGame: game)
    }

    if ability.description(forGame: .ruby) != nil {
        ability.generationIntroduced = 3
    } else if ability.description(forGame: .diamond) != nil {
        ability.generationIntroduced = 4
    } else if ability.description(forGame: .black) != nil {
        ability.generationIntroduced = 5
    } else if ability.description(forGame: .x) != nil {
        ability.generationIntroduced = 6
    } else if ability.description(forGame: .sun) != nil {
        ability.generationIntroduced = 7
    } else if ability.description(forGame: .sword) != nil {
        ability.generationIntroduced = 8
    } else if ability.description(forGame: .scarlet) != nil {
        ability.generationIntroduced = 9
    }
}

// Copy abilities to national
for (_, ability) in allAbilities {
    for game in Game.allGamesNewestFirst {
        if let latestDescription = ability.description(forGame: game) {
            ability.setDescription(latestDescription, forGame: .national)
            break
        }
    }
}

// Copy Sword abilities to Brilliant Diamond & Shining Pearl
for (_, ability) in allAbilities {
    if let description = ability.description(forGame: .sword) {
        if ability.description(forGame: .brilliantDiamond) == nil {
            ability.setDescription(description, forGame: .brilliantDiamond)
        } else {
            debugPrint("\(ability.name) already has a description for Brilliant Diamond")
        }
        if ability.description(forGame: .shiningPearl) == nil {
            ability.setDescription(description, forGame: .shiningPearl)
        } else {
            debugPrint("\(ability.name) already has a description for Shining Pearl")
        }
    }
}


// MARK: - Moves
print("--- Moves ---")

func latestMove(name: String, moves: [Game: StoredMove]) -> StoredMove? {
    for generation in Generation.allCases {
        for game in generation.games {
            if let move = moves[game] {
                return move
            }
        }
    }
    return nil
}

let moveDescriptionsDict = Helper.loadJSON(from: "Data/MoveDescriptions.json") as! [String: [String: String]]
let moveExternalLinkDict = Helper.loadExternalLinksTSV(from: "Research/MoveExternalLinks.tsv")
for (moveName, dict) in Helper.loadJSON(from: "Data/Moves.json") as! [String: [String: String]] {
    let generationIntroduced = Generation(dictValue: dict["generationIntroduced"]!)!

    let key = sanitizedMoveName(moveName)
    var moves: [Game: StoredMove] = [:]
    Generation.allCases
        .reversed()
        .filter { $0 >= generationIntroduced && $0 != .all }
        .map { $0.games }
        .flatMap { $0 }
        .forEach { game in

            // TODO: Revisit whether to use this after Scarlet/Violet data is more available
            let moveDescription: String
            if let description = dict[game.rawValue] ?? moveDescriptionsDict[key]?[Game.pokemonDBKey(for: game)] {
                moveDescription = description
            } else {
                if let description = moves.keys.sorted().reversed().lazy.compactMap({ moves[$0]?.moveDescription }).first {
                    debugPrint("No description found for move \(moveName) in game \(game), using latest description")
                    moveDescription = description
                } else {
                    debugPrint("No description found for move \(moveName) in game \(game), using default description")
                    moveDescription = "This move has no description."
                }
            }
//            guard let moveDescription = dict[game.rawValue] ?? moveDescriptionsDict[key]?[Game.pokemonDBKey(for: game)] else {
//                debugPrint("No description found for move \(moveName) in game \(game), skipping")
//                return
//            }

            let move = StoredMove(context: moc)
            move.name = moveName
            move.index = Int(dict["number"]!)!
            move.type = PokemonType(rawValue: dict["type"]!)!
            move.generationIntroduced = generationIntroduced
            move.game = game
            move.accuracy = Int(dict["accuracy"] ?? "")
            move.category = MoveCategory(dictValue: dict["category"] ?? "") ?? .varies
            move.maxPP = Int(dict["maxPP"] ?? "")
            move.power = Int(dict["power"] ?? "")
            move.pp = Int(dict["pp"] ?? "")
            move.targetAlly1 = Int(dict["targetAlly1"]!)! == 1
            move.targetAlly2 = Int(dict["targetAlly2"]!)! == 1
            move.targetEnemy1 = Int(dict["targetFoe1"]!)! == 1
            move.targetEnemy2 = Int(dict["targetFoe2"]!)! == 1
            move.targetEnemy3 = Int(dict["targetFoe3"]!)! == 1
            move.targetSelf = Int(dict["targetSelf"]!)! == 1
            move.targetDescription = dict["targetDescription"]!.removingQuotes()
            move.moveDescription = moveDescription

            let externalLinks = moveExternalLinkDict[sanitizedMoveName(moveName)]!
            move.bulbapediaURL = Helper.sanitizedURL(from: externalLinks["bulbapediaURL"]!)!
            move.pokemonDBURL = Helper.sanitizedURL(from: externalLinks["pokemonDBURL"]!)!


            moves[game] = move
    }

    // Copy most recent generation default game over to National
    if let existingMove = latestMove(name: moveName, moves: moves) {
        debugPrint("Copying move \(existingMove.name) over to national")
        let move = StoredMove(context: moc)
        move.name = existingMove.name
        move.index = existingMove.index
        move.type = existingMove.type
        move.generationIntroduced = existingMove.generationIntroduced
        move.game = .national
        move.accuracy = existingMove.accuracy
        move.category = existingMove.category
        move.maxPP = existingMove.maxPP
        move.power = existingMove.power
        move.pp = existingMove.pp
        move.targetAlly1 = existingMove.targetAlly1
        move.targetAlly2 = existingMove.targetAlly2
        move.targetEnemy1 = existingMove.targetEnemy1
        move.targetEnemy2 = existingMove.targetEnemy2
        move.targetEnemy3 = existingMove.targetEnemy3
        move.targetSelf = existingMove.targetSelf
        move.targetDescription = existingMove.targetDescription
        move.moveDescription = existingMove.moveDescription
        move.bulbapediaURL = existingMove.bulbapediaURL
        move.pokemonDBURL = existingMove.pokemonDBURL
        moves[.national] = move
    }

    allMoves[key] = moves
}


// MARK: - Machines
print("--- Machines ---")
func processMachineTSV(filename: String, game: Game, machineType: MachineType) -> [Int: StoredMachine] {
    var machines: [Int: StoredMachine] = [:]
    for dict in Helper.loadTSV(from: filename) {
        let move = getMove(forName: dict["name"]!, game: game)!
        let number = Int(dict["number"]!)!
        let machine = StoredMachine(context: moc)
        machine.game = game
        machine.move = move
        machine.number = number
        machine.type = machineType
        machines[number] = machine
    }
    return machines
}

allTMs[.red] = processMachineTSV(filename: "Research/TMs/Gen 1-Table 1.tsv", game: .red, machineType: .tm)
allTMs[.blue] = processMachineTSV(filename: "Research/TMs/Gen 1-Table 1.tsv", game: .blue, machineType: .tm)
allTMs[.yellow] = processMachineTSV(filename: "Research/TMs/Gen 1-Table 1.tsv", game: .yellow, machineType: .tm)
allTMs[.gold] = processMachineTSV(filename: "Research/TMs/Gen 2-Table 1.tsv", game: .gold, machineType: .tm)
allTMs[.silver] = processMachineTSV(filename: "Research/TMs/Gen 2-Table 1.tsv", game: .silver, machineType: .tm)
allTMs[.crystal] = processMachineTSV(filename: "Research/TMs/Gen 2-Table 1.tsv", game: .crystal, machineType: .tm)
allTMs[.ruby] = processMachineTSV(filename: "Research/TMs/Gen 3-Table 1.tsv", game: .ruby, machineType: .tm)
allTMs[.sapphire] = processMachineTSV(filename: "Research/TMs/Gen 3-Table 1.tsv", game: .sapphire, machineType: .tm)
allTMs[.emerald] = processMachineTSV(filename: "Research/TMs/Gen 3-Table 1.tsv", game: .emerald, machineType: .tm)
allTMs[.fireRed] = processMachineTSV(filename: "Research/TMs/Gen 3-Table 1.tsv", game: .fireRed, machineType: .tm)
allTMs[.leafGreen] = processMachineTSV(filename: "Research/TMs/Gen 3-Table 1.tsv", game: .leafGreen, machineType: .tm)
allTMs[.diamond] = processMachineTSV(filename: "Research/TMs/Gen 4-Table 1.tsv", game: .diamond, machineType: .tm)
allTMs[.pearl] = processMachineTSV(filename: "Research/TMs/Gen 4-Table 1.tsv", game: .pearl, machineType: .tm)
allTMs[.platinum] = processMachineTSV(filename: "Research/TMs/Gen 4-Table 1.tsv", game: .platinum, machineType: .tm)
allTMs[.heartGold] = processMachineTSV(filename: "Research/TMs/Gen 4-Table 1.tsv", game: .heartGold, machineType: .tm)
allTMs[.soulSilver] = processMachineTSV(filename: "Research/TMs/Gen 4-Table 1.tsv", game: .soulSilver, machineType: .tm)
allTMs[.black] = processMachineTSV(filename: "Research/TMs/Gen 5-Table 1.tsv", game: .black, machineType: .tm)
allTMs[.white] = processMachineTSV(filename: "Research/TMs/Gen 5-Table 1.tsv", game: .white, machineType: .tm)
allTMs[.black2] = processMachineTSV(filename: "Research/TMs/Gen 5-Table 1.tsv", game: .black2, machineType: .tm)
allTMs[.white2] = processMachineTSV(filename: "Research/TMs/Gen 5-Table 1.tsv", game: .white2, machineType: .tm)
allTMs[.x] = processMachineTSV(filename: "Research/TMs/XY-Table 1.tsv", game: .x, machineType: .tm)
allTMs[.y] = processMachineTSV(filename: "Research/TMs/XY-Table 1.tsv", game: .y, machineType: .tm)
allTMs[.omegaRuby] = processMachineTSV(filename: "Research/TMs/ORAS-Table 1.tsv", game: .omegaRuby, machineType: .tm)
allTMs[.alphaSapphire] = processMachineTSV(filename: "Research/TMs/ORAS-Table 1.tsv", game: .alphaSapphire, machineType: .tm)
allTMs[.sun] = processMachineTSV(filename: "Research/TMs/SMUSUM-Table 1.tsv", game: .sun, machineType: .tm)
allTMs[.moon] = processMachineTSV(filename: "Research/TMs/SMUSUM-Table 1.tsv", game: .moon, machineType: .tm)
allTMs[.ultraSun] = processMachineTSV(filename: "Research/TMs/SMUSUM-Table 1.tsv", game: .ultraSun, machineType: .tm)
allTMs[.ultraMoon] = processMachineTSV(filename: "Research/TMs/SMUSUM-Table 1.tsv", game: .ultraMoon, machineType: .tm)
allTMs[.letsGoPikachu] = processMachineTSV(filename: "Research/TMs/LGPLGE-Table 1.tsv", game: .letsGoPikachu, machineType: .tm)
allTMs[.letsGoEevee] = processMachineTSV(filename: "Research/TMs/LGPLGE-Table 1.tsv", game: .letsGoEevee, machineType: .tm)
allTMs[.sword] = processMachineTSV(filename: "Research/TMs/Gen 8-Table 1.tsv", game: .sword, machineType: .tm)
allTMs[.shield] = processMachineTSV(filename: "Research/TMs/Gen 8-Table 1.tsv", game: .shield, machineType: .tm)
allTMs[.brilliantDiamond] = processMachineTSV(filename: "Research/TMs/BDSP-Table 1.tsv", game: .brilliantDiamond, machineType: .tm)
allTMs[.shiningPearl] = processMachineTSV(filename: "Research/TMs/BDSP-Table 1.tsv", game: .shiningPearl, machineType: .tm)
allTMs[.scarlet] = processMachineTSV(filename: "Research/TMs/SV-Table 1.tsv", game: .scarlet, machineType: .tm)
allTMs[.violet] = processMachineTSV(filename: "Research/TMs/SV-Table 1.tsv", game: .violet, machineType: .tm)

allTMs[.national] = processMachineTSV(filename: "Research/TMs/Gen 8-Table 1.tsv", game: .national, machineType: .tm)

allHMs[.red] = processMachineTSV(filename: "Research/HMs/Gen 1-Table 1.tsv", game: .red, machineType: .hm)
allHMs[.blue] = processMachineTSV(filename: "Research/HMs/Gen 1-Table 1.tsv", game: .blue, machineType: .hm)
allHMs[.yellow] = processMachineTSV(filename: "Research/HMs/Gen 1-Table 1.tsv", game: .yellow, machineType: .hm)
allHMs[.gold] = processMachineTSV(filename: "Research/HMs/Gen 2-Table 1.tsv", game: .gold, machineType: .hm)
allHMs[.silver] = processMachineTSV(filename: "Research/HMs/Gen 2-Table 1.tsv", game: .silver, machineType: .hm)
allHMs[.crystal] = processMachineTSV(filename: "Research/HMs/Gen 2-Table 1.tsv", game: .crystal, machineType: .hm)
allHMs[.ruby] = processMachineTSV(filename: "Research/HMs/RSE-Table 1.tsv", game: .ruby, machineType: .hm)
allHMs[.sapphire] = processMachineTSV(filename: "Research/HMs/RSE-Table 1.tsv", game: .sapphire, machineType: .hm)
allHMs[.emerald] = processMachineTSV(filename: "Research/HMs/RSE-Table 1.tsv", game: .emerald, machineType: .hm)
allHMs[.fireRed] = processMachineTSV(filename: "Research/HMs/FRLG-Table 1.tsv", game: .fireRed, machineType: .hm)
allHMs[.leafGreen] = processMachineTSV(filename: "Research/HMs/FRLG-Table 1.tsv", game: .leafGreen, machineType: .hm)
allHMs[.diamond] = processMachineTSV(filename: "Research/HMs/DPPt-Table 1.tsv", game: .diamond, machineType: .hm)
allHMs[.pearl] = processMachineTSV(filename: "Research/HMs/DPPt-Table 1.tsv", game: .pearl, machineType: .hm)
allHMs[.platinum] = processMachineTSV(filename: "Research/HMs/DPPt-Table 1.tsv", game: .platinum, machineType: .hm)
allHMs[.heartGold] = processMachineTSV(filename: "Research/HMs/HGSS-Table 1.tsv", game: .heartGold, machineType: .hm)
allHMs[.soulSilver] = processMachineTSV(filename: "Research/HMs/HGSS-Table 1.tsv", game: .soulSilver, machineType: .hm)
allHMs[.black] = processMachineTSV(filename: "Research/HMs/Gen 5-Table 1.tsv", game: .black, machineType: .hm)
allHMs[.white] = processMachineTSV(filename: "Research/HMs/Gen 5-Table 1.tsv", game: .white, machineType: .hm)
allHMs[.black2] = processMachineTSV(filename: "Research/HMs/Gen 5-Table 1.tsv", game: .black2, machineType: .hm)
allHMs[.white2] = processMachineTSV(filename: "Research/HMs/Gen 5-Table 1.tsv", game: .white2, machineType: .hm)
allHMs[.x] = processMachineTSV(filename: "Research/HMs/XY-Table 1.tsv", game: .x, machineType: .hm)
allHMs[.y] = processMachineTSV(filename: "Research/HMs/XY-Table 1.tsv", game: .y, machineType: .hm)
allHMs[.omegaRuby] = processMachineTSV(filename: "Research/HMs/ORAS-Table 1.tsv", game: .omegaRuby, machineType: .hm)
allHMs[.alphaSapphire] = processMachineTSV(filename: "Research/HMs/ORAS-Table 1.tsv", game: .alphaSapphire, machineType: .hm)

allTRs[.sword] = processMachineTSV(filename: "Research/TRs.tsv", game: .sword, machineType: .tr)
allTRs[.shield] = processMachineTSV(filename: "Research/TRs.tsv", game: .shield, machineType: .tr)

allTRs[.national] = processMachineTSV(filename: "Research/TRs.tsv", game: .national, machineType: .tr)


// MARK: - Pokemon
print("--- Pokemon ---")
for dict in Helper.loadTSV(from: "Research/Pokemon.tsv") {
    let name = dict["name"]!
    let index = Int(dict["number"]!)!
    var pokemons: [Game: StoredPokemon] = [:]

    for game in Game.allCases {
        let pokemon = StoredPokemon(context: moc)
        pokemon.index = index
        pokemon.name = name
        pokemon.game = game
        pokemon.generationIntroduced = Generation(rawValue: Int(dict["introduced"]!)!)!
        pokemon.catchRate = Int(dict["catchRate"]!)!
        pokemon.levelingRate = LevelingRate(dictValue: dict["levelingRate"]!)!
        if let maleRatioString = dict["maleRatio"], !maleRatioString.isEmpty {
            pokemon.maleRatio = Double(maleRatioString)
        } else {
            pokemon.maleRatio = nil
        }
        pokemon.eggGroups = [dict["eggGroup1"], dict["eggGroup2"]]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .map { EggGroup(dictValue: $0)! }
        pokemon.bulbapediaURL = Helper.sanitizedURL(from: dict["bulbapediaURL"]!)!
        pokemon.pokemonDBURL = Helper.sanitizedURL(from: dict["pokemonDBURL"]!)!

        pokemons[game] = pokemon
    }

    allPokemon[index] = pokemons
    allPokemonByName[sanitizedName(name)] = pokemons
}

allPokemonByName.keys
    .sorted { $0 < $1 }
    .enumerated()
    .forEach {
        pokemonNameIndices[$0.element] = $0.offset
}


// MARK: - Pokedex Numbers
print("--- Pokedex Numbers ---")
let allPokedexNumbers: [Int: [Game: StoredPokedexNumbers]] = allPokemon.keys
    .reduce(into: [:]) { dict, index in
        var numbers: [Game: StoredPokedexNumbers] = [:]
        for game in Game.allCases {
            numbers[game] = StoredPokedexNumbers(context: moc)
        }
        dict[index] = numbers
    }
for index in allPokemon.keys {
    let pokemon = allPokemon[index]!
    let pokedexNumbers = allPokedexNumbers[index]!
    for game in Game.allCases {
        pokemon[game]!.pokedexNumbers = pokedexNumbers[game]!
    }
}
//zip(allPokemon.keys.sorted().map { allPokemon[$0]! }, allPokedexNumbers.keys.sorted().map { allPokedexNumbers[$0]! }).forEach {
//    for game in Game.allCases {
//        $0[game]!.pokedexNumbers = $1[game]!
//    }
//}

func processPokedexNumberTSV(filename: String, dictKey: String, pokedexNumberKey: String) {

    func convertNumberString(_ numberString: String) -> Int { Int(numberString.replacingOccurrences(of: "#", with: ""))! }

    for dict in Helper.loadTSV(from: filename) {
        let national = convertNumberString(dict["national"]!)
        let numberString = dict[dictKey]!
        guard !numberString.isEmpty else { continue }
        let regionalNumber = convertNumberString(numberString)
        let pokedexNumbers = allPokedexNumbers[national]!
        pokedexNumbers.values.forEach { $0.setValue(regionalNumber, forKey: pokedexNumberKey) }
    }
}

processPokedexNumberTSV(filename: "Research/PokedexNumbers/Alola-Table 1.tsv", dictKey: "alola", pokedexNumberKey: #keyPath(StoredPokedexNumbers.z_alola))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/Alola-Table 1.tsv", dictKey: "melemele", pokedexNumberKey: #keyPath(StoredPokedexNumbers.z_melemele))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/Alola-Table 1.tsv", dictKey: "akala", pokedexNumberKey: #keyPath(StoredPokedexNumbers.z_akala))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/Alola-Table 1.tsv", dictKey: "ulaula", pokedexNumberKey: #keyPath(StoredPokedexNumbers.z_ulaula))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/Alola-Table 1.tsv", dictKey: "poni", pokedexNumberKey: #keyPath(StoredPokedexNumbers.z_poni))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/CentralKalos-Table 1.tsv", dictKey: "centralKalos", pokedexNumberKey: #keyPath(StoredPokedexNumbers.z_centralKalos))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/CoastalKalos-Table 1.tsv", dictKey: "coastalKalos", pokedexNumberKey: #keyPath(StoredPokedexNumbers.z_coastalKalos))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/CrownTundra-Table 1.tsv", dictKey: "crownTundra", pokedexNumberKey: #keyPath(StoredPokedexNumbers.z_crownTundra))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/Galar-Table 1.tsv", dictKey: "galar", pokedexNumberKey: #keyPath(StoredPokedexNumbers.z_galar))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/Hoenn-Table 1.tsv", dictKey: "hoenn", pokedexNumberKey: #keyPath(StoredPokedexNumbers.z_hoenn))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/IsleOfArmor-Table 1.tsv", dictKey: "isleOfArmor", pokedexNumberKey: #keyPath(StoredPokedexNumbers.z_isleOfArmor))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/Johto-Table 1.tsv", dictKey: "johto", pokedexNumberKey: #keyPath(StoredPokedexNumbers.z_johto))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/Kanto-Table 1.tsv", dictKey: "kanto", pokedexNumberKey: #keyPath(StoredPokedexNumbers.z_kanto))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/MountainKalos-Table 1.tsv", dictKey: "mountainKalos", pokedexNumberKey: #keyPath(StoredPokedexNumbers.z_mountainKalos))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/National-Table 1.tsv", dictKey: "national", pokedexNumberKey: #keyPath(StoredPokedexNumbers.z_national))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/NewHoenn-Table 1.tsv", dictKey: "newHoenn", pokedexNumberKey: #keyPath(StoredPokedexNumbers.z_newHoenn))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/NewJohto-Table 1.tsv", dictKey: "newJohto", pokedexNumberKey: #keyPath(StoredPokedexNumbers.z_newJohto))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/NewKanto-Table 1.tsv", dictKey: "kanto", pokedexNumberKey: #keyPath(StoredPokedexNumbers.z_letsGoKanto))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/NewUnova-Table 1.tsv", dictKey: "newUnova", pokedexNumberKey: #keyPath(StoredPokedexNumbers.z_newUnova))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/PearlSinnoh-Table 1.tsv", dictKey: "sinnoh", pokedexNumberKey: #keyPath(StoredPokedexNumbers.z_sinnoh)) // "PearlSinnoh" should actually be "PlatinumSinnoh" but w/e
processPokedexNumberTSV(filename: "Research/PokedexNumbers/Sinnoh-Table 1.tsv", dictKey: "sinnoh", pokedexNumberKey: #keyPath(StoredPokedexNumbers.z_newSinnoh)) // Brilliant Diamond & Shining Pearl
processPokedexNumberTSV(filename: "Research/PokedexNumbers/UltraAlola-Table 1.tsv", dictKey: "alola", pokedexNumberKey: #keyPath(StoredPokedexNumbers.z_ultraAlola))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/UltraAlola-Table 1.tsv", dictKey: "melemele", pokedexNumberKey: #keyPath(StoredPokedexNumbers.z_ultraMelemele))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/UltraAlola-Table 1.tsv", dictKey: "akala", pokedexNumberKey: #keyPath(StoredPokedexNumbers.z_ultraAkala))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/UltraAlola-Table 1.tsv", dictKey: "ulaula", pokedexNumberKey: #keyPath(StoredPokedexNumbers.z_ultraUlaula))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/UltraAlola-Table 1.tsv", dictKey: "poni", pokedexNumberKey: #keyPath(StoredPokedexNumbers.z_ultraPoni))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/Unova-Table 1.tsv", dictKey: "unova", pokedexNumberKey: #keyPath(StoredPokedexNumbers.z_unova))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/Hisui-Table 1.tsv", dictKey: "hisui", pokedexNumberKey: #keyPath(StoredPokedexNumbers.z_hisui))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/Paldea-Table 1.tsv", dictKey: "paldea", pokedexNumberKey: #keyPath(StoredPokedexNumbers.z_paldea))


// MARK: - Pokemon Forms
print("--- Pokemon Forms ---")
var pokemonFormDebugKeys: Set<String> = []
for dict in Helper.loadTSV(from: "Research/PokemonForms.tsv") {
    let index = Int(dict["number"]!)!
    let game = Game(dictValue: dict["game"]!)!

    let pokemon = allPokemon[index]![game]!
    var gameForms = pokemon.forms

    let formName = dict["formName"]!

    let debugKey = ["\(index)", pokemon.name, formName, game.rawValue].joined(separator: ",")
    assert(!pokemonFormDebugKeys.contains(debugKey), debugKey)
    pokemonFormDebugKeys.insert(debugKey)

    let storedForm = StoredPokemonForm(context: moc)
    storedForm.name = formName
    storedForm.index = index
    storedForm.formIndex = gameForms.count
    storedForm.pokemonIndex = pokemon.index
    storedForm.i_pokemonNameIndex = Int32(pokemonNameIndices[sanitizedName(pokemon.name)]!)
    storedForm.game = game
    storedForm.familyName = dict["familyName"]!
    storedForm.species = dict["species"]!
    storedForm.primaryType = PokemonType(rawValue: dict["primaryType"]!)!
    if let secondaryTypeString = dict["secondaryType"], !secondaryTypeString.isEmpty {
        storedForm.secondaryType = PokemonType(rawValue: secondaryTypeString)!
    }
    storedForm.color = PokemonColor(rawValue: dict["color"]!.lowercased())!
    storedForm.pokedexEntry = dict["pokedexEntry"]!.removingQuotes()
    storedForm.heightInMeters = Double(dict["height"]!)!
    storedForm.weightInKilograms = Double(dict["weight"]!)!
    storedForm.baseExperienceYield = Int(dict["baseXPYield"]!)!
    storedForm.baseFriendship = Int(dict["baseFriendship"]!)!

    let primaryAbility = getAbility(forName: sanitizedName(dict["abilityPrimary"]!))
    if game.generation >= primaryAbility.generationIntroduced
        || !game.hasAbilities {
        storedForm.primaryAbility = primaryAbility
    }

    if let ability2Name = dict["abilitySecondary"], !ability2Name.isEmpty {
        let secondaryAbility = getAbility(forName: sanitizedName(ability2Name))
        if secondaryAbility.generationIntroduced <= game.generation
            || !game.hasAbilities {
            storedForm.secondaryAbility = secondaryAbility
        }
    }

    if let abilityHiddenName = dict["abilityHidden"], !abilityHiddenName.isEmpty {
        let hiddenAbility = getAbility(forName: sanitizedName(abilityHiddenName))
        if hiddenAbility.generationIntroduced <= game.generation
            || !game.hasAbilities {
            storedForm.hiddenAbility = hiddenAbility
        }
    }

    let baseStats = StoredStats(context: moc)
    baseStats.hp = Int(dict["baseHP"]!)!
    baseStats.attack = Int(dict["baseATK"]!)!
    baseStats.defense = Int(dict["baseDEF"]!)!
    baseStats.specialAttack = Int(dict["baseSATK"]!)!
    baseStats.specialDefense = Int(dict["baseSDEF"]!)!
    baseStats.speed = Int(dict["baseSPD"]!)!
    storedForm.baseStats = baseStats

    let evYield = StoredStats(context: moc)
    evYield.hp = Int(dict["evHP"]!)!
    evYield.attack = Int(dict["evATK"]!)!
    evYield.defense = Int(dict["evDEF"]!)!
    evYield.specialAttack = Int(dict["evSATK"]!)!
    evYield.specialDefense = Int(dict["evSDEF"]!)!
    evYield.speed = Int(dict["evSPD"]!)!
    storedForm.evYield = evYield

    gameForms.append(storedForm)
    pokemon.forms = gameForms
}

// Copy latest available PokemonForm to national
func latestPokemon(_ pokemons: [Game: StoredPokemon]) -> StoredPokemon {
    for game in Game.allGamesNewestFirstExceptNational {
        if let matchingPokemon = pokemons[game],
           !matchingPokemon.forms.isEmpty {
            return matchingPokemon
        }
    }

    fatalError("Should never get here")
//    // fallback to arceus
//    return pokemons[.legendsArceus]
}
//func makeNationalPokemonForm(from sourceForm: StoredPokemonForm) -> StoredPokemonForm {
//    let nationalForm = StoredPokemonForm(context: moc)
//    nationalForm.name = sourceForm.name
//    nationalForm.index = sourceForm.index
//    nationalForm.formIndex = sourceForm.formIndex
//    nationalForm.pokemonIndex = sourceForm.pokemonIndex
//    nationalForm.i_pokemonNameIndex = sourceForm.i_pokemonNameIndex
//    nationalForm.game = .national
//    nationalForm.familyName = sourceForm.familyName
//    nationalForm.species = sourceForm.species
//    nationalForm.primaryType = sourceForm.primaryType
//    nationalForm.secondaryType = sourceForm.secondaryType
//    nationalForm.color = sourceForm.color
//    nationalForm.pokedexEntry = sourceForm.pokedexEntry
//    nationalForm.heightInMeters = sourceForm.heightInMeters
//    nationalForm.weightInKilograms = sourceForm.weightInKilograms
//    nationalForm.baseExperienceYield = sourceForm.baseExperienceYield
//    nationalForm.baseFriendship = sourceForm.baseFriendship
//
//    nationalForm.primaryAbility = sourceForm.primaryAbility
//    nationalForm.secondaryAbility = sourceForm.secondaryAbility
//    nationalForm.hiddenAbility = sourceForm.hiddenAbility
//
//    let baseStats = StoredStats(context: moc)
//    baseStats.hp = sourceForm.baseStats.hp
//    baseStats.attack = sourceForm.baseStats.attack
//    baseStats.defense = sourceForm.baseStats.defense
//    baseStats.specialAttack = sourceForm.baseStats.specialAttack
//    baseStats.specialDefense = sourceForm.baseStats.specialDefense
//    baseStats.speed = sourceForm.baseStats.speed
//    nationalForm.baseStats = baseStats
//
//    let evYield = StoredStats(context: moc)
//    evYield.hp = sourceForm.evYield.hp
//    evYield.attack = sourceForm.evYield.attack
//    evYield.defense = sourceForm.evYield.defense
//    evYield.specialAttack = sourceForm.evYield.specialAttack
//    evYield.specialDefense = sourceForm.evYield.specialDefense
//    evYield.speed = sourceForm.evYield.speed
//    nationalForm.evYield = evYield
//
//    return nationalForm
//}
//func copyPokemonForms(from source: StoredPokemon, to destination: StoredPokemon) {
//    let sourceForms = source.forms
//    var destinationForms: [StoredPokemonForm] = []
//
//    for sourceForm in sourceForms {
//        let nationalForm = makeNationalPokemonForm(from: sourceForm)
//        destinationForms.append(nationalForm)
//    }
//    destination.forms = destinationForms
//}
//func copyLegendsArceusForms(from source: StoredPokemon, to destination: StoredPokemon) {
//    let sourceForms = source.forms
//    var destinationForms = destination.forms
//
//    for sourceForm in sourceForms {
//        guard sourceForm.name.lowercased().contains("hisuian")
//                && !destinationForms.contains(where: { $0.name == sourceForm.name }) else { continue }
//        let nationalForm = makeNationalPokemonForm(from: sourceForm)
//
//        // Modify the form index to be the current count (making it +1). We need to manually
//        // compensate here, because we're adding the Hisuian form on top of what's already been
//        // added from the latest set of forms, so if we didn't change the form index, it would
//        // be off.
//        nationalForm.formIndex = destinationForms.count
//
//        destinationForms.append(nationalForm)
//    }
//    destination.forms = destinationForms
//}
//
//for (_, pokemons) in allPokemon {
//    guard let latestPokemon = latestPokemon(pokemons) else { continue }
//    let nationalPokemon = pokemons[.national]!
//    copyPokemonForms(from: latestPokemon, to: nationalPokemon)
//
//    if let legendsArceusPokemon = pokemons[.legendsArceus] {
//        copyLegendsArceusForms(from: legendsArceusPokemon, to: nationalPokemon)
//    }
//}


// MARK: - Pokemon Moves
print("--- Pokemon Moves ---")
let asteriskCharacterSet = CharacterSet(charactersIn: "*")
let galarianSanitizedFormPokemon = ["Darmanitan"]
func sanitizedLevelForms(_ forms: [StoredPokemonForm], forFormName formName: String, pokemonName: String) -> [StoredPokemonForm] {
    var forms = forms
    if galarianSanitizedFormPokemon.contains(pokemonName) {
        if formName.contains("Galarian") {
            forms.removeAll(where: { $0.name.contains("Galarian") })
        } else {
            forms.removeAll(where: { !$0.name.contains("Galarian") })
        }
    } else if formName != pokemonName || forms.contains(where: { $0.name.contains("Galarian") || $0.name.contains("Alolan") }),
        let form = forms.first(where: { $0.name == formName }) {
        return [form]
    }
    return forms
}


// MARK: Level
print("Level")
var levelLearnsetEntries: [String: StoredLearnsetEntry] = [:]

let moveNameMappings = Helper.loadTSV(from: "Research/MoveFormNameMappings.tsv")
func sanitizedLevelingForms(_ forms: [StoredPokemonForm], pokemonName: String, formFilter: String?) -> [StoredPokemonForm] {
    guard let formFilter = formFilter else { return forms }

    let filteredForms = forms.filter { $0.name.lowercased() == formFilter.lowercased() }
    if !filteredForms.isEmpty {
        return filteredForms
    } else if let mapping = moveNameMappings.first(where: { $0["name"] == pokemonName && $0["formFilter"]! == formFilter }) {
        let mappedFormNames = mapping["formNames"]!.trimmingCharacters(in: .alphanumerics.inverted).components(separatedBy: ",")
        return forms.filter { mappedFormNames.contains($0.name) }
    } else {
        return []
    }
}

func addLearnsetLevelEntry(
    level: Int,
    game: Game,
    move: StoredMove,
    pokemon: StoredPokemon,
    form: StoredPokemonForm
) {
    let debugKey = "\(pokemon.name) \(form.name) \(game.rawValue) \(move.name) \(level)"
    guard levelLearnsetEntries[debugKey] == nil else {
        print(debugKey)
        print(levelLearnsetEntries[debugKey]!)
        print(pokemon.name)
        print(form.name)
        print(game)
        print(move.name)
        fatalError()
    }

    let entry = StoredLearnsetEntry(context: moc)
    entry.level = level
    entry.move = move
    entry.form = form
    entry.game = game
    entry.learnsetType = .level
    levelLearnsetEntries[debugKey] = entry
}

for (pokemonName, dict) in Helper.loadJSON(from: "Data/LearnsetLevel3.json") as! [String: [String: [String: [[String: String]]]]] {
    guard !dict.isEmpty else { continue }
    for (_, gameDicts) in dict {
        guard !gameDicts.isEmpty else { continue }
        for (gameAndFormKey, moveDicts) in gameDicts {
            let components = gameAndFormKey.components(separatedBy: ".")
            let gameKey = components[0]
            let formFilter: String? = components.count > 1 ? components.dropFirst().joined(separator: ".") : nil

            let game = Game(rawValue: gameKey)!
            let pokemon = getPokemon(forName: pokemonName, game: game)
            var forms = pokemon.forms
            guard !pokemon.forms.isEmpty else { print("\(NumberFormatter.pokemonIndex.string(from: NSNumber(value: pokemon.index))!) \(pokemonName): No forms found for \(pokemon.name) in game \(game)"); continue }
            forms = sanitizedLevelingForms(forms, pokemonName: pokemonName, formFilter: formFilter)
            if forms.isEmpty {
                print("\(pokemonName): No forms found for form name \(formFilter ?? "") in game \(game), skipping")
                continue
//                print("\(pokemonName): No forms found for form name \(formFilter ?? "") in game \(game), falling back to all forms")
//                forms = pokemon.forms
            }
            for form in forms {
                for moveDict in moveDicts {
                    let name = moveDict["name"]!
                    let level = Int(moveDict["level"]!.trimmingCharacters(in: asteriskCharacterSet)) ?? 1
                    guard let move = getMove(forName: name, game: game) else {
                        continue
                    }

                    addLearnsetLevelEntry(
                        level: level,
                        game: game,
                        move: move,
                        pokemon: pokemon,
                        form: form
                    )
                }
            }
        }
    }
}


// MARK: Machine
print("Machine")

func addLearnsetMachineEntry(form: StoredPokemonForm, machine: StoredMachine, game: Game) {
    let entry = StoredLearnsetEntry(context: moc)
    entry.machine = machine
    entry.form = form
    entry.game = game
    entry.move = machine.move
    entry.learnsetType = .machine
}

for (pokemonName, dict) in Helper.loadJSON(from: "Data/LearnsetMachines3.json") as! [String: [String: [String: [String]]]] {
    guard !dict.isEmpty else { continue }
    for (_, gameDicts) in dict {
        guard !gameDicts.isEmpty else { continue }
        for (gameAndFormKey, machines) in gameDicts {
            let components = gameAndFormKey.components(separatedBy: ".")
            let gameKey = components[0]
            let formFilter: String? = components.count > 1 ? components.dropFirst().joined(separator: ".") : nil
            let game = Game(rawValue: gameKey)!
            let pokemon = getPokemon(forName: pokemonName, game: game)
            var forms = pokemon.forms
            guard !pokemon.forms.isEmpty else { print("\(NumberFormatter.pokemonIndex.string(from: NSNumber(value: pokemon.index))!) \(pokemonName): No forms found for form name \(formFilter ?? "") in game \(game)"); continue }
            forms = sanitizedLevelingForms(forms, pokemonName: pokemonName, formFilter: formFilter)
            guard !forms.isEmpty else { print("\(pokemonName): No forms found for form name \(formFilter ?? "") in game \(game)"); continue }
            for form in forms {
                for machine in machines {
                    let machineNumber = Int(machine.trimmingCharacters(in: .uppercaseLetters))!
                    let resolvedMachine: StoredMachine?
                    if machine.hasPrefix("TM") {
                        resolvedMachine = allTMs[game]![machineNumber]
                    } else if machine.hasPrefix("HM") {
                        resolvedMachine = allHMs[game]![machineNumber]
                    } else if machine.hasPrefix("TR") {
                        resolvedMachine = allTRs[game]![machineNumber]
                    } else {
                        fatalError()
                    }
                    guard resolvedMachine != nil else { print("Could not find machine for \(machine) in game \(game)"); continue }
                    addLearnsetMachineEntry(form: form, machine: resolvedMachine!, game: game)
                }
            }
        }
    }
}


// MARK: Breeding
print("Breeding")

func correctBreedingName(_ name: String) -> String {
    guard name.lowercased().hasPrefix("Nidoran") else { return name }
    if name == "NidoranM" {
        return "Nidoran\u{2642}"
    } else if name == "Lycnaroc" {
        return "Lycanroc"
    } else if name == "Doduro" {
        return "Doduo"
    } else {
        return name
    }
}

func addLearnsetBreedingEntry(form: StoredPokemonForm, move: StoredMove, fathers: [StoredPokemon], game: Game) {
    let entry = StoredLearnsetEntry(context: moc)
    entry.form = form
    entry.move = move
    entry.fathers = fathers
    entry.game = game
    entry.learnsetType = .breeding
    breedingLearnsetEntries.append(entry)
}

var breedingLearnsetEntries: [StoredLearnsetEntry] = []
for (pokemonName, dict) in Helper.loadJSON(from: "Data/LearnsetBreeding.json") as! [String: [String: [String: [String]]]] {
    for (generationKey, moveDicts) in dict {
        let games = Game.allGames(forLearnsetValue: generationKey)!
        for game in games {
            let pokemon = getPokemon(forName: pokemonName, game: game)
            let forms = pokemon.forms
            guard !forms.isEmpty else { continue }
            for (moveName, parentNames) in moveDicts {
                guard let move = getMove(forName: moveName, game: game) else {
                    continue
                }
                let fathers: [StoredPokemon] = parentNames
                    .filter {
                        $0 != "Missingno."
                        && $0 != "866"
                        && $0 != "Pokémon XD: Gale of Darkness"
                        && $0 != "File:664MS3.png"
                        && $0 != "File:666MS3.png"
                    }
                    .compactMap {
                        let fatherName = correctBreedingName($0)
                        let candidate = getPokemon(forName: fatherName, game: game)
                        guard !candidate.forms.isEmpty else { return nil }
                        return candidate
                    }
                for form in forms {
                    addLearnsetBreedingEntry(form: form, move: move, fathers: fathers, game: game)
                }
            }
        }
    }
}


// MARK: Tutoring
print("Tutoring")

func addLearnsetTutoringEntry(form: StoredPokemonForm, move: StoredMove, game: Game) {
    let entry = StoredLearnsetEntry(context: moc)
    entry.form = form
    entry.move = move
    entry.game = game
    entry.learnsetType = .tutoring
}

for (pokemonName, dict) in Helper.loadJSON(from: "Data/LearnsetTutoring3.json") as! [String: [String: [String: [String]]]] {
    guard !dict.isEmpty else { continue }
    for (_, gameDicts) in dict {
        guard !gameDicts.isEmpty else { continue }
        for (gameAndFormKey, moveNames) in gameDicts {
            let components = gameAndFormKey.components(separatedBy: ".")
            let gameKey = components[0]
            let formFilter: String? = components.count > 1 ? components.dropFirst().joined(separator: ".") : nil
            let game = Game(rawValue: gameKey)!
            let pokemon = getPokemon(forName: pokemonName, game: game)
            var forms = pokemon.forms
            guard !pokemon.forms.isEmpty else { print("\(NumberFormatter.pokemonIndex.string(from: NSNumber(value: pokemon.index))!) \(pokemonName): No forms found for form name \(formFilter ?? "") in game \(game)"); continue }
            forms = sanitizedLevelingForms(forms, pokemonName: pokemonName, formFilter: formFilter)
            guard !forms.isEmpty else { print("\(pokemonName): No forms found for form name \(formFilter ?? "") in game \(game)"); continue }
            for form in forms {
                for moveName in moveNames {
                    guard let move = getMove(forName: moveName, game: game) else {
                        continue
                    }
                    addLearnsetTutoringEntry(form: form, move: move, game: game)
                }
            }
        }
    }
}

func copyLearnsetEntry(_ source: StoredLearnsetEntry, form: StoredPokemonForm, game: Game) {
    let copy = StoredLearnsetEntry(context: moc)
    copy.form = form

    copy.game = game
    copy.level = source.level
    copy.move = getMove(forName: source.move.name, game: game)!
    copy.learnsetType = source.learnsetType
    copy.fathers = source.fathers.map { getPokemon(forName: $0.name, game: game) }
    copy.machine = source.machine
}

// If any forms have missing learnset data, copy them over from the main form
for (game, pokemon) in allPokemon.flatMap({ $0.value }) {
    // We can have Pokemon with no forms, if they don't exist in the game,
    // they'll be cleaned up at the end of the script.
    guard let defaultForm = pokemon.forms.first, pokemon.forms.count > 1 else { continue }

    let defaultLearnset = defaultForm.z_learnsetEntries!.allObjects as! [StoredLearnsetEntry]
    for form in pokemon.forms.dropFirst() {
        let formLearnsetEntries = (form.z_learnsetEntries ?? .init()).allObjects as! [StoredLearnsetEntry]

        if !formLearnsetEntries.contains(where: { $0.learnsetType == .level }) {
            let defaultLevelLearnset = defaultLearnset.filter { $0.learnsetType == .level }

            for source in defaultLevelLearnset {
                copyLearnsetEntry(source, form: form, game: game)
            }
        }

        if !formLearnsetEntries.contains(where: { $0.learnsetType == .machine }) {
            let defaultMachineLearnset = defaultLearnset.filter { $0.learnsetType == .machine }

            for source in defaultMachineLearnset {
                copyLearnsetEntry(source, form: form, game: game)
            }
        }

        if !formLearnsetEntries.contains(where: { $0.learnsetType == .breeding }) {
            let defaultBreedingLearnset = defaultLearnset.filter { $0.learnsetType == .breeding }

            for source in defaultBreedingLearnset {
                copyLearnsetEntry(source, form: form, game: game)
            }
        }

        if !formLearnsetEntries.contains(where: { $0.learnsetType == .tutoring }) {
            let defaultTutoringLearnset = defaultLearnset.filter { $0.learnsetType == .tutoring }

            for source in defaultTutoringLearnset {
                copyLearnsetEntry(source, form: form, game: game)
            }
        }
    }
}

func copyMoves(from latestForm: StoredPokemonForm, to nationalForm: StoredPokemonForm) {
    let latestEntries = latestForm.z_learnsetEntries!.allObjects as! [StoredLearnsetEntry]
    for source in latestEntries {
        copyLearnsetEntry(source, form: nationalForm, game: .national)
    }
}

func latestPokemonForm(
    forFormName formName: String,
    gameToPokemon: [Game: StoredPokemon]
) -> StoredPokemonForm {
    for game in Game.allGamesNewestFirstExceptNational {
        guard let pokemon = gameToPokemon[game] else { continue }
        if let form = pokemon.forms.first(where: { $0.name == formName }) {
            return form
        }
    }
    fatalError()
}

// Copy moves to national
for (_, gameToPokemon) in allPokemonByName {
    let national = gameToPokemon[.national]!
    for nationalForm in national.forms {
        let latestForm = latestPokemonForm(forFormName: nationalForm.name, gameToPokemon: gameToPokemon)
        copyMoves(from: latestForm, to: nationalForm)
    }


//    let latest = latestPokemon(gameToPokemon)
//    let national = gameToPokemon[.national]!
//    for (latestForm, nationalForm) in zip(latest.forms, national.forms) {
//        copyMoves(from: latestForm, to: nationalForm)
//    }

//    if let legendsArceusPokemon = gameToPokemon[.legendsArceus], legendsArceusPokemon !== latest {
//        for legendsArceusForm in legendsArceusPokemon.forms where legendsArceusForm.name.lowercased().contains("hisuian") {
//            guard let nationalForm = national.forms.first(where: { $0.name == legendsArceusForm.name }) else { continue }
//            copyMoves(from: legendsArceusForm, to: nationalForm)
//        }
//    }
}


// MARK: - Locations
print("--- Locations ---")
let locationPercentFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .percent
    return formatter
}()
func resolveLocationName(forLocationName locationName: String, game: Game) -> String {
    if ["Team Magma/Aqua Hideout"].contains(locationName) {
        if game == .ruby || game == .emerald || game == .omegaRuby {
            return "Team Magma Hideout"
        } else if game == .sapphire || game == .emerald || game == .alphaSapphire {
            return "Team Aqua Hideout"
        } else {
            return locationName
        }
    } else {
        return locationName
    }
}
func resolveRegionName(forLocationName locationName: String, regionName: String) -> String {
    if ["kanto", "hoenn"].contains(regionName.lowercased()),
        [
            "One Island",
            "Two Island",
            "Three Island",
            "Four Island",
            "Five Island",
            "Six Island",
            "Seven Island",
            "Treasure Beach",
            "Kindle Road",
            "Cape Brink",
            "Bond Bridge",
            "Three Isle Port",
            "Three Isle Path",
            "Resort Gorgeous",
            "Water Labyrinth",
            "Five Isle Meadow",
            "Memorial Pillar",
            "Outcast Island",
            "Green Path",
            "Water Path",
            "Ruin Valley",
            "Trainer Tower",
            "Canyon Entrance",
            "Sevault Canyon",
            "Tanoby Ruins",
            "Mt. Ember",
            "Berry Forest",
            "Icefall Cave",
            "Rocket Warehouse",
            "Lost Cave",
            "Altering Cave",
            "Pattern Bush",
            "Dotted Hole",
            "Tanoby Key",
            "Tanoby Chambers",
            "Navel Rock",
            "Birth Island"
            ].contains(locationName) {
        return Region.seviiIslands.rawValue
    } else {
        return regionName
    }
}
let locationExternalLinksDict: [String: [String: String]] = {
    let file = Helper.loadTSV(from: "Research/LocationExternalLinks.tsv")
    var retVal: [String: [String: String]] = [:]
    for dict in file {
        let region = dict["region"]!
        let name = dict["name"]!
        let key = "\(region)-\(name)"
        retVal[key] = dict
    }
    return retVal
}()
func getOrMakeLocation(withName locationNameCandidate: String, regionName: String, game: Game) -> StoredLocation {
    let location: StoredLocation
    let locationName = resolveLocationName(forLocationName: locationNameCandidate, game: game)
    let resolvedRegionName = resolveRegionName(forLocationName: locationName, regionName: regionName)
    if let existingLocation = getLocation(forName: locationName, region: resolvedRegionName, game: game) {
        location = existingLocation
    } else {
        location = StoredLocation(context: moc)
        location.name = locationName
        location.region = Region(rawValue: resolvedRegionName)!
        location.game = game

        if let externalLinksDict = locationExternalLinksDict["\(regionName)-\(locationName)"] ?? locationExternalLinksDict["\(resolvedRegionName)-\(locationName)"] {
            location.bulbapediaURL = Helper.sanitizedURL(from: externalLinksDict["bulbapediaURL"]!)
            location.pokemonDBURL = Helper.sanitizedURL(from: externalLinksDict["pokemonDBURL"]!)
        }

        setLocation(location, forName: locationName, region: resolvedRegionName, game: game)
    }
    return location
}
var locationCaptureMethods: Set<CaptureMethod> = []
func processLocationDict(locationName: String, regionName: String, locationDict: [String: [String: [String: Any]]]) {
    for (generationNumber, areaDicts) in locationDict {
        for (areaName, areaDict) in areaDicts {
            for (methodName, methodAny) in areaDict {
                let methodDict = methodAny as! [String: Any]
                let encounterMethodDicts = methodDict["pokemon"] as! [String: [[String: Any]]]
                for (encounterCondition, pokemonDicts) in encounterMethodDicts {
                    for pokemonDict in pokemonDicts {
                        let games = (pokemonDict["games"] as! [String]).map { Game(locationAbbreviation: $0, generation: Generation(rawValue: Int(generationNumber)!)!) }
                        for game in games {
                            let location = getOrMakeLocation(withName: locationName, regionName: regionName, game: game)

                            let name = pokemonDict["name"] as! String
                            let pokemon = getPokemon(forName: name, game: game)

                            let rarity = pokemonDict["rarity"] as! String
                            let encounterRate: EncounterRate
                            if let rarityInt = Int(rarity.trimmingCharacters(in: CharacterSet(charactersIn: "%"))) {
                                encounterRate = EncounterRate(rateType: .percent, rate: "\(rarityInt)")
                            } else if rarity.lowercased() == "unknown" {
                                encounterRate = .unknown
                            } else {
                                encounterRate = EncounterRate(rateType: .rarity, rate: rarity)
                            }

                            let levels = pokemonDict["levels"] as! String
                            let levelLow: Int
                            let levelHigh: Int?
                            if levels != "—" {
                                let levelComponents = levels.components(separatedBy: "-")
                                levelLow = Int(levelComponents[0])!
                                if levelComponents.count == 2 {
                                    levelHigh = Int(levelComponents[1])!
                                } else {
                                    levelHigh = nil
                                }
                            } else {
                                levelLow = 0
                                levelHigh = nil
                            }

                            let detail = (pokemonDict["description"] as? String)?.removingQuotes()

                            let timeOfDay = (pokemonDict["times_of_day"] as? [String])?.map { TimeOfDay(rawValue: $0)! }

                            let locationPokemon = StoredLocationPokemon(context: moc)
                            locationPokemon.pokemon = pokemon
                            locationPokemon.detail = detail
                            locationPokemon.area = areaName
                            locationPokemon.captureMethod = CaptureMethod(rawValue: methodName)!
                            locationPokemon.levelLow = levelLow
                            locationPokemon.levelHigh = levelHigh
                            locationPokemon.timeOfDay = timeOfDay
                            locationPokemon.encounterCondition = encounterCondition.removingQuotes()
                            locationPokemon.encounterRate = encounterRate
                            locationPokemon.game = game
                            locationPokemon.location = location

                            locationCaptureMethods.insert(locationPokemon.captureMethod)
                        }
                    }
                }
            }
        }
    }
}
for (regionName, regionDict) in Helper.loadJSON(from: "Data/PokemonLocations.json") as! [String: [String: [String: [String: [String: Any]]]]] {
    for (locationName, locationDict) in regionDict {
        guard !(locationName == "Fortree City" && regionName == "hoenn") else { continue }
        processLocationDict(locationName: locationName, regionName: regionName, locationDict: locationDict)
    }
}
for (regionName, regionDict) in Helper.loadJSON(from: "Research/ManualPokemonLocations.json") as! [String: [String: [String: [String: [String: Any]]]]] {
    for (locationName, locationDict) in regionDict {
        processLocationDict(locationName: locationName, regionName: regionName, locationDict: locationDict)
    }
}

func makeLocationPokemonCopy(source: StoredLocationPokemon, pokemon: StoredPokemon, game: Game) {
    let destination = StoredLocationPokemon(context: moc)
    destination.pokemon = pokemon
    destination.detail = source.detail
    destination.area = source.area
    destination.captureMethod = source.captureMethod
    destination.levelLow = source.levelLow
    destination.levelHigh = source.levelHigh
    destination.timeOfDay = source.timeOfDay
    destination.encounterCondition = source.encounterCondition
    destination.encounterRate = source.encounterRate
    destination.game = game
    destination.location = getOrMakeLocation(withName: source.location.name, regionName: source.location.region.rawValue, game: game)
}

// Copy locations to national
for (_, gameToPokemon) in allPokemonByName {
    let latest = latestPokemon(gameToPokemon)
    let national = gameToPokemon[.national]!
    let locationPokemons = latest.z_locationPokemons!.allObjects as! [StoredLocationPokemon]

    for source in locationPokemons {
        makeLocationPokemonCopy(source: source, pokemon: national, game: .national)
    }
}

func makeGrandUndergroundLocation(for game: Game) {
    let location: StoredLocation
    location = StoredLocation(context: moc)
    location.name = "Grand Underground"
    location.region = .sinnoh
    location.game = game
    location.bulbapediaURL = URL(string: "https://bulbapedia.bulbagarden.net/wiki/Grand_Underground")!
    location.pokemonDBURL = nil

    setLocation(location, forName: location.name, region: Region.sinnoh.rawValue, game: game)
}
makeGrandUndergroundLocation(for: .brilliantDiamond)
makeGrandUndergroundLocation(for: .shiningPearl)
makeGrandUndergroundLocation(for: .national)


// MARK: Galar Wild Dens
let wildDenStarKeys = ["one", "two", "three", "four", "five"]
for (locationName, locationDict) in Helper.loadJSON(from: "Data/PokemonWildDen.json") as! [String: [String: [String: [[String: Any]]]]] {
    for (denName, denDict) in locationDict {
        for (poolName, poolDicts) in denDict {
            let area = "Den \(denName)"

            for poolDict in poolDicts {
                var games: [Game] = []
                if poolDict["sword"] as? Bool == true {
                    games.append(.sword)
                }
                if poolDict["shield"] as? Bool == true {
                    games.append(.shield)
                }

                games.forEach { game in
                    let location = getLocation(forName: locationName, region: "galar", game: game)!
                    for (star, key) in wildDenStarKeys.enumerated() {
                        let percentString = poolDict[key] as! String
                        guard percentString != "0%" else { continue }

                        let level = -(star + 1)
                        let percent = Int(percentString.trimmingCharacters(in: CharacterSet(charactersIn: "%")))! // negative for stars

                        let locationPokemon = StoredLocationPokemon(context: moc)
                        locationPokemon.pokemon = getPokemon(forName: poolDict["pokemon"] as! String, game: game)
                        locationPokemon.location = location
                        locationPokemon.game = game
                        locationPokemon.area = area
                        locationPokemon.levelLow = level
                        locationPokemon.encounterCondition = poolName.removingQuotes()
                        locationPokemon.encounterRate = .percent(percent)
                        locationPokemon.captureMethod = .wildDen

                        locationCaptureMethods.insert(.wildDen)
                    }
                }
            }
        }
    }
}

//print("Location capture methods")
//print(locationCaptureMethods)

// MARK: Location Maps
for mapDict in Helper.loadTSV(from: "Research/LocationMaps.tsv") {
    let locationName = mapDict["location"]!
    let region = mapDict["region"]!
    let game = Game(rawValue: mapDict["game"]!)!
    let location = getOrMakeLocation(withName: locationName, regionName: region, game: game)

    let areaName = mapDict["areaName"]!
    let filename = mapDict["filename"]!

    let locationMap = StoredLocationMap(context: moc)
    locationMap.location = location
    locationMap.areaName = areaName
    locationMap.filename = filename
}


allLocations.values.forEach {
    $0.values
        .sorted {
            if $0.name == $1.name {
                return $0.region < $1.region
            } else {
                return $0.name < $1.name
            }
    }
    .enumerated()
    .forEach { i, location in
        location.i_nameIndex = Int32(i)
    }
}

// MARK: - Items
print("--- Items ---")
let bulbapediaItems = try! JSONDecoder().decode([BulbapediaItem].self, from: Helper.loadJSONData(from: "Data/BulbapediaItems.json"))
let pokemonDBItems = try! JSONDecoder().decode([String: [String: String]].self, from: Helper.loadJSONData(from: "Data/PokemonDBItems.json"))
let itemExternalLinksBulbapedia = Helper.loadExternalLinksTSV(from: "Research/ItemExternalLinksBulbapedia.tsv")
let itemExternalLinksPokemonDB = Helper.loadExternalLinksTSV(from: "Research/ItemExternalLinksPokemonDB.tsv")

func itemDescriptionFromPokemonDB(name: String, game: Game) -> String? {
    var candidates = [game]
    if game == .omegaRuby {
        candidates.append(.ruby)
    } else if game == .alphaSapphire {
        candidates.append(.sapphire)
    }

    let keys = candidates.map(Game.pokemonDBKey)

    var name = name
    name = name.replacingOccurrences(of: "Bicycle", with: "Bike")

    guard let item = pokemonDBItems[name] else {
        print("Could not find PokemonDB item for name \(name)")
        return nil
    }

    guard let description = keys.compactMap({ item[$0] }).first else {
        print("Could not find PokemonDB description for item \(name), game: \(game)")
        return nil
    }
    return description
}

//func convertGen7ItemToGen8(_ name: String) {
//    let index = bulbapediaItems.firstIndex(where: { $0.name == name })!
//    let existing = bulbapediaItems[index]
//
//    var descriptions = existing.descriptions
//    descriptions[Game.sword.rawValue] = descriptions[Game.ultraSun.rawValue]
//    descriptions[Game.shield.rawValue] = descriptions[Game.ultraMoon.rawValue]
//
//    var pocket = existing.pocket
//    pocket["Generation VIII"] = pocket["Generation VII"]
//
//    var prices = existing.prices ?? [:]
//    prices[Game.sword.rawValue] = prices[Game.ultraSun.rawValue]
//    prices[Game.shield.rawValue] = prices[Game.ultraMoon.rawValue]
//
//    let modified = BulbapediaItem(
//        descriptions: descriptions,
//        generationIntroduced: existing.generationIntroduced,
//        imageName: existing.imageName,
//        name: existing.name,
//        pocket: pocket,
//        prices: prices)
//    bulbapediaItems[index] = modified
//}
//
//["Oval Stone",
// "Dragon Scale",
// "Upgrade",
// "Dubious Disc"
//    ].forEach { convertGen7ItemToGen8($0) }

for bulbapediaItem in bulbapediaItems {
    print("Processing item \(bulbapediaItem.name)")

    for game in Game.allGamesNewestFirstExceptNational {
        var gameForInfo = game
        let generationIntroduced = Generation(rawValue: Int(bulbapediaItem.generationIntroduced)!)!
        if generationIntroduced == .i {
            switch gameForInfo {
            case .red:
                gameForInfo = .gold
            case .blue:
                gameForInfo = .silver
            case .yellow:
                gameForInfo = .crystal
            default:
                break
            }
        }
        
        let bulbapediaItemInfo = bulbapediaItem.itemInfo(for: gameForInfo)
        let key = sanitizedItemName(bulbapediaItem.name)
        
        guard !bulbapediaItem.name.lowercased().hasSuffix("berry"),
              allItems[key]?[game] == nil,
              let itemDescription = itemDescriptionFromPokemonDB(name: bulbapediaItem.name, game: game)
                ?? bulbapediaItemInfo.description?.removingQuotes() else {
            continue
        }

        let item = StoredItem(context: moc)
        item.name = bulbapediaItem.name
        item.game = game
        item.i_gameIndex = Int32(game.index)
        item.generationIntroduced = generationIntroduced
        item.imageName = bulbapediaItem.imageName.removingDiacritics()
        item.itemType = .item
        item.itemDescription = itemDescription
        item.bulbapediaURL = URL(string: itemExternalLinksBulbapedia[sanitizedItemName(item.name)]!["bulbapediaURL"]!)!
        if let pokemonDBURLString = itemExternalLinksPokemonDB[sanitizedItemName(item.name)]?["pokemonDBURL"] {
            item.pokemonDBURL = URL(string: pokemonDBURLString)
        }

        let info = StoredBagItemInfo(context: moc)
        info.itemDescription = itemDescription
        info.cost = bulbapediaItemInfo.price?.cost?.toNSNumber()
        info.sell = bulbapediaItemInfo.price?.sell?.toNSNumber()

        if generationIntroduced == .i {
            info.pocket = .items
        } else {
            info.pocket = bulbapediaItemInfo.pocket
        }

        item.bagInfo = info

        if var items = allItems[key] {
            items[game] = item
            allItems[key] = items
        } else {
            allItems[key] = [game: item]
        }
    }
}

//// Manual items
//// For items that are now in Sword/Shield, but their individual Bulbapedia
//// wiki pages haven't been updated with Sword/Shield data yet. This copies over
//// the data from UltraSun.
//func insertSwordShieldItem(forName name: String, game: Game) {
//    let usumItem = allItems[sanitizedItemName(name)]![.ultraSun]!
//
//    let item = StoredItem(context: moc)
//    item.name = usumItem.name
//    item.game = game
//    item.i_gameIndex = Int32(game.index)
//    item.generationIntroduced = usumItem.generationIntroduced
//    item.imageName = usumItem.imageName
//    item.itemType = usumItem.itemType
//    item.itemDescription = usumItem.bagInfo!.itemDescription
//
//    let info = StoredBagItemInfo(context: moc)
//    info.itemDescription = usumItem.bagInfo!.itemDescription
//    info.cost = usumItem.bagInfo!.cost
//    info.sell = usumItem.bagInfo!.sell
//    info.pocket = usumItem.bagInfo!.pocket
//    item.bagInfo = info
//
//    let key = sanitizedItemName(item.name)
//    if var items = allItems[key] {
//        items[game] = item
//        allItems[key] = items
//    } else {
//        allItems[key] = [game: item]
//    }
//}
//insertSwordShieldItem(forName: "Electirizer", game: .sword)
//insertSwordShieldItem(forName: "Electirizer", game: .shield)
//insertSwordShieldItem(forName: "Magmarizer", game: .sword)
//insertSwordShieldItem(forName: "Magmarizer", game: .shield)

for dict in Helper.loadTSV(from: "Research/Berries.tsv") {
    let game = Game(rawValue: dict["game"]!)!
    let item = StoredItem(context: moc)
    item.name = dict["name"]!
    item.game = game
    item.i_gameIndex = Int32(item.game.index)
    item.generationIntroduced = Generation(rawValue: Int(dict["generation"]!)!)!
    item.imageName = item.name.lowercased().replacingOccurrences(of: " ", with: "-").removingDiacritics()
    item.itemType = .berry
    item.itemDescription = itemDescriptionFromPokemonDB(name: item.name, game: game) ?? dict["description"]!.removingQuotes()
    item.bulbapediaURL = URL(string: itemExternalLinksBulbapedia[sanitizedItemName(item.name)]!["bulbapediaURL"]!)!
    if let pokemonDBURLString = itemExternalLinksPokemonDB[sanitizedItemName(item.name)]?["pokemonDBURL"] {
        item.pokemonDBURL = URL(string: pokemonDBURLString)
    }

    let info = StoredBerryItemInfo(context: moc)
    info.itemDescription = itemDescriptionFromPokemonDB(name: item.name, game: game) ?? dict["description"]!.removingQuotes()
    info.firmness = dict["firmness"] != "" ? BerryFirmness(rawValue: dict["firmness"]!)! : nil
    info.spicy = dict["spicy"] != "" ? Int16(dict["spicy"]!)! : -1
    info.dry = dict["dry"] != "" ? Int16(dict["dry"]!)! : -1
    info.sweet = dict["sweet"] != "" ? Int16(dict["sweet"]!)! : -1
    info.bitter = dict["bitter"] != "" ? Int16(dict["bitter"]!)! : -1
    info.sour = dict["sour"] != "" ? Int16(dict["sour"]!)! : -1

    item.berryInfo = info

    let key = sanitizedItemName(item.name)
    if var items = allItems[key] {
        items[game] = item
        allItems[key] = items
    } else {
        allItems[key] = [game: item]
    }
}

func latestItem(_ items: [Game: StoredItem]) -> StoredItem? {
    var gameCandidates = Game.allGamesNewestFirstExceptNational
    gameCandidates.removeAll { $0 == .national }
    for game in gameCandidates {
        if let matchingItem = items[game] {
            return matchingItem
        }
    }
    return nil
}

func makeItemCopy(source: StoredItem) -> StoredItem {
    let copy = StoredItem(context: moc)
    copy.name = source.name
    copy.generationIntroduced = source.generationIntroduced
    copy.imageName = source.imageName
    copy.itemType = source.itemType
    copy.itemDescription = source.itemDescription
    copy.bulbapediaURL = source.bulbapediaURL
    copy.pokemonDBURL = source.pokemonDBURL

    if let info = source.bagInfo {
        let destinationInfo = StoredBagItemInfo(context: moc)
        destinationInfo.itemDescription = info.itemDescription
        destinationInfo.cost = info.cost
        destinationInfo.sell = info.sell
        destinationInfo.pocket = info.pocket
        copy.bagInfo = destinationInfo
    }

    if let info = source.berryInfo {
        let destinationInfo = StoredBerryItemInfo(context: moc)
        destinationInfo.itemDescription = info.itemDescription
        destinationInfo.firmness = info.firmness
        destinationInfo.spicy = info.spicy
        destinationInfo.dry = info.dry
        destinationInfo.sweet = info.sweet
        destinationInfo.bitter = info.bitter
        destinationInfo.sour = info.sour
        copy.berryInfo = destinationInfo
    }
    return copy
}

// Copy items to national, using latest data
for (_, gameToItem) in allItems {
    guard let source = latestItem(gameToItem) else { continue }

    let copy = makeItemCopy(source: source)
    copy.game = .national
    copy.i_gameIndex = Game.national.index.toInt32()

    let key = sanitizedItemName(copy.name)
    if var items = allItems[key] {
        items[.national] = copy
        allItems[key] = items
    } else {
        allItems[key] = [.national: copy]
    }
}

// Copy items to scarlet/violet, using national
for (_, gameToItem) in allItems where gameToItem[.scarlet] == nil {
    guard let source = gameToItem[.national] else { continue }

    let scarletCopy = makeItemCopy(source: source)
    scarletCopy.game = .scarlet
    scarletCopy.i_gameIndex = Game.scarlet.index.toInt32()

    let violetCopy = makeItemCopy(source: source)
    violetCopy.game = .violet
    violetCopy.i_gameIndex = Game.violet.index.toInt32()

    let key = sanitizedItemName(source.name)
    if var items = allItems[key] {
        items[.scarlet] = scarletCopy
        items[.violet] = violetCopy
        allItems[key] = items
    } else {
        allItems[key] = [
            .scarlet: scarletCopy,
            .violet: violetCopy
        ]
    }
}

//// Copy all Gen 1-4 items to Brilliant Diamond / Shining Pearl
//var bdspItemCount = 0
//for (_, gameToItem) in allItems {
//    guard let generationIntroduced = gameToItem.first?.value.generationIntroduced,
//          generationIntroduced <= .iv,
//          let source = latestItem(gameToItem) else {
//        continue
//    }
//
//    let brilliantDiamondCopy = makeItemCopy(source: source)
//    brilliantDiamondCopy.game = .brilliantDiamond
//    brilliantDiamondCopy.i_gameIndex = Game.brilliantDiamond.index.toInt32()
//    let brilliantDiamondKey = sanitizedItemName(brilliantDiamondCopy.name)
//    if var items = allItems[brilliantDiamondKey] {
//        items[.brilliantDiamond] = brilliantDiamondCopy
//        allItems[brilliantDiamondKey] = items
//    } else {
//        allItems[brilliantDiamondKey] = [.brilliantDiamond: brilliantDiamondCopy]
//    }
//
//    let shiningPearlCopy = makeItemCopy(source: source)
//    shiningPearlCopy.game = .shiningPearl
//    shiningPearlCopy.i_gameIndex = Game.shiningPearl.index.toInt32()
//    let shiningPearlKey = sanitizedItemName(shiningPearlCopy.name)
//    if var items = allItems[shiningPearlKey] {
//        items[.shiningPearl] = shiningPearlCopy
//        allItems[shiningPearlKey] = items
//    } else {
//        allItems[shiningPearlKey] = [.shiningPearl: shiningPearlCopy]
//    }
//
//    bdspItemCount += 1
//}
//print("Copied over \(bdspItemCount) items to BDSP")

allItems.keys
    .sorted()
    .enumerated()
    .forEach { i, key in
        let index = Int32(i)
        allItems[key]!.values.forEach { $0.i_nameIndex = index }
    }


// MARK: - Evolutions
print("--- Evolutions ---")
var allEvolutions: [String: [Game: [StoredEvolution]]] = [:] // family name as key
func latestEvolutionForNational(familyName: String) -> [StoredEvolution]? {
    guard let evolutions = allEvolutions[familyName] else { return nil }
    for game in Game.allGamesNewestFirstExceptNational {
        if let evolution = evolutions[game] {
            return evolution
        }
    }
    return nil
}
func evolutionMethod(for name: String, data: String, game: Game) -> EvolutionMethod? {
    switch name {
    case "completeBattlePerformingAction":
        return .completeBattlePerformingAction(data)
    case "friendship":
        return .friendship
    case "levelUp":
        return .levelUp(Int(data)!)
    case "levelUpHoldingItem":
        guard let item = getItem(forName: data, game: game) else {
            debugPrint("Could not find item named \(data) in \(game)")
            return nil
        }
        return .levelUpHoldingItem(item)
    case "levelUpInArea":
        return .levelUpInArea(data)
    case "levelUpKnowingMove":
        guard let move = getMove(forName: data, game: game) else {
            debugPrint("Could not find move named \(data) in \(game)")
            return nil
        }
        return .levelUpKnowingMove(move)
    case "levelUpWithPartyMember":
        return .levelUpWithPartyMember(getPokemon(forName: data, game: game))
    case "levelUpWithStats":
        return .levelUpWithStats(data)
    case "other":
        return .other(data)
    case "trade":
        return .trade
    case "tradeForPokemon":
        let pokemon = getPokemon(forName: data, game: game)
        return .tradeForPokemon(pokemon)
    case "tradeHoldingItem":
        guard let item = getItem(forName: data, game: game) else {
            debugPrint("Could not find item named \(data) in \(game)")
            return nil
        }
        return .tradeHoldingItem(item)
    case "trainerAction":
        return .trainerAction(data)
    case "useItem":
        guard let item = getItem(forName: data, game: game) else {
            debugPrint("Could not find item named \(data) in \(game)")
            return nil
        }
        return .useItem(item)
    default:
        fatalError()
    }
}
func evolutionCondition(for name: String, data: String, game: Game) -> EvolutionCondition? {
    switch name {
    case "deviceHeldUpsideDown":
        return .deviceHeldUpsideDown
    case "gender":
        return .gender(Gender(rawValue: data)!)
    case "haveAbility":
        return .haveAbility(getAbility(forName: data))
    case "other":
        return .other(data)
    case "partyMemberType":
        return .partyMemberType(PokemonType(rawValue: data)!)
    case "region":
        return .region(Region(rawValue: data.lowercased())!)
    case "timeOfDay":
        return .timeOfDay(TimeOfDay(rawValue: data.capitalized)!)
    case "weather":
        return .weather(Weather(rawValue: data)!)
    default:
        return nil
    }
}
for dict in Helper.loadTSV(from: "Research/Evolutions.tsv") {
    let familyName = dict["family"]!
    let gameFilter = dict["gameFilter"]!.components(separatedBy: ",").compactMap(Game.init(rawValue:))
    let excludeGames = dict["excludeGames"]!.components(separatedBy: ",").compactMap(Game.init(rawValue:))
    let baseName = dict["baseName"]!
    let baseFormName = dict["baseFormName"]!
    let targetName = dict["targetName"]!
    let targetFormName = dict["targetFormName"]!
    let methodName = dict["methodName"]!
    let methodData = dict["methodData"]!
    let requirementName = dict["requirementName"]!
    let requirementData = dict["requirementData"]!
    let requirementName2 = dict["requirementName2"]!
    let requirementData2 = dict["requirementData2"]!

    guard let basePokemons = allPokemonByName[sanitizedName(baseName)],
          let targetPokemons = allPokemonByName[sanitizedName(targetName)] else {
        debugPrint("Could not find evolution pair for base pokemon \(baseName) and target pokemon \(targetName), skipping")
        continue
    }

    var games = !gameFilter.isEmpty ? gameFilter : Array(basePokemons.keys)
    games = games.filter { !excludeGames.contains($0) }

    for game in games.sorted(by: >) { // Go in reverse game order, so we copy the latest data over to national
        let basePokemon = basePokemons[game]!
        guard let targetPokemon = targetPokemons[game] else {
            print("No target for \(basePokemon.name) in game \(game)")
            continue
        }

        guard let baseForm = baseFormName == "" ? basePokemon.forms.first : basePokemon.forms.first(where: { $0.name == baseFormName }),
              let targetForm = targetFormName == "" ? targetPokemon.forms.first : targetPokemon.forms.first(where: { $0.name == targetFormName }) else {
            continue
        }

        let evolution = StoredEvolution(context: moc)
        evolution.familyName = familyName
        evolution.game = game
        evolution.from = baseForm
        evolution.to = targetForm
        guard let method = evolutionMethod(for: methodName, data: methodData, game: game) else {
            debugPrint("Could not resolve evolution method for \(baseName).\(baseFormName)-\(targetName).\(targetFormName), method \(methodName).\(methodData) in game \(game), skipping")
            continue
        }
        evolution.method = method
        evolution.condition = evolutionCondition(for: requirementName, data: requirementData, game: game)
        evolution.condition2 = evolutionCondition(for: requirementName2, data: requirementData2, game: game)

        let key = familyName
        if var existingEvolutions = allEvolutions[key] {
            var existingPerGame = existingEvolutions[game] ?? []

            if game == .national {
                // Prevent adding duplicate entries for national
                guard !existingPerGame.contains(where: {
                    existing in
                    existing.from.name == evolution.from.name && existing.to.name == evolution.to.name
                }) else {
                    continue
                }
            }

            existingPerGame.append(evolution)
            existingEvolutions[game] = existingPerGame
            allEvolutions[key] = existingEvolutions
        } else {
            allEvolutions[key] = [game: [evolution]]
        }
    }
}

allPokemon.values
    .flatMap { $0.values }
    .flatMap { $0.forms }
    .forEach { form in
        form.evolutions = allEvolutions[form.familyName]?[form.game]
    }



// MARK: - Cleanup
print("--- Cleanup ---")

// Cleanup Pokemon that don't have forms
allPokemon.values
    .flatMap { $0.values }
    .filter { $0.forms.isEmpty }
    .forEach { moc.delete($0) }

// Cleanup BreedLearnsetEntry's that have no fathers
// This happens when the generation has the breeding move,
// but there are no fathers that exist in that game, and
// have been cleaned up in the Pokemon cleanup.
breedingLearnsetEntries
    .filter { $0.fathers.isEmpty }
    .forEach { moc.delete($0) }

print()
print("Done importing!")
let date = Date()
do {
    try moc.save()
    print("Saved database to: \(container.persistentStoreDescriptions.first!.url!.absoluteString)")
    print("Took \(Date().timeIntervalSince(date)) seconds to save")
} catch {
    print("Failed to save database: \(error)")
}

print("Finished importing in \(Date().timeIntervalSince(start)) seconds!")
