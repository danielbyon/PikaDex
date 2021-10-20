//
//  main.swift
//  DatabaseLoader
//
//  Created by Daniel Byon on 1/2/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import CoreData


// MARK: - Global Variables
let container = Helper.loadContainer(removeExistingContainer: true)
let moc = container.viewContext
var allPokemon: [Int: [Game: StoredPokemon]] = [:]
var allPokemonByName: [String: [Game: StoredPokemon]] = [:]
var pokemonNameIndices: [String: Int] = [:]
var allAbilities: [String: Ability] = [:]
var allItems: [String: [Game: Item]] = [:]
var allMoves: [String: [Game: Move]] = [:]
var allTMs: [Game: [Int: Machine]] = [:]
var allHMs: [Game: [Int: Machine]] = [:]
var allTRs: [Game: [Int: Machine]] = [:]
var allLocations: [Game: [String: Location]] = [:]


// MARK: - Global Helpers
let validNameCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "♂♀"))
func sanitizedName(_ name: String) -> String {
    String(name.lowercased().unicodeScalars.filter { validNameCharacters.contains($0) })
}
func sanitizedItemName(_ name: String, game: Game) -> String {
    sanitizedName(name) + "\(game.index)"
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
    }
    return allPokemonByName[sanitizedName(name)]![game]!
}
func getItem(forName name: String, game: Game) -> Item? {
    allItems[sanitizedItemName(name, game: game)]![game]
}
func getMove(forName name: String, game: Game) -> Move? {
    allMoves[sanitizedMoveName(name)]![game]
}
func getAbility(forName name: String) -> Ability {
    allAbilities[sanitizedName(name)]!
}
func getLocation(forName locationName: String, region: String, game: Game) -> Location? {
    allLocations[game]?[locationName + region]
}
func setLocation(_ location: Location, forName locationName: String, region: String, game: Game) {
    var gameLocations = allLocations[game] ?? [:]
    gameLocations[locationName + region] = location
    allLocations[game] = gameLocations
}

// MARK: - Main
print("Pokedex Database Loader")
print()
let start = Date()


// MARK: - Abilities
print("--- Abilities ---")
func gamesForAbilityKey(_ key: String) -> [Game]? {
    switch key {
    case "Pokémon Ruby and Sapphire Versions":
        return [.ruby, .sapphire]
    case "Pokémon Emerald Version":
        return [.emerald]
    case "Pokémon FireRed and LeafGreen Versions":
        return [.fireRed, .leafGreen]
    case "Pokémon Diamond and Pearl Versions":
        return [.diamond, .pearl]
    case "Pokémon Platinum Version":
        return [.platinum]
    case "Pokémon HeartGold and SoulSilver Versions":
        return [.heartGold, .soulSilver]
    case "Pokémon Black and White Versions":
        return [.black, .white]
    case "Pokémon Black and White Versions 2":
        return [.black2, .white2]
    case "Pokémon X and Y":
        return [.x, .y]
    case "Pokémon Omega Ruby and Alpha Sapphire":
        return [.omegaRuby, .alphaSapphire]
    case "Pokémon Sun and Moon":
        return [.sun, .moon]
    case "Pokémon Ultra Sun and Ultra Moon":
        return [.ultraSun, .ultraMoon]
    case "Pokémon Sword and Shield":
        return [.sword, .shield]
    case "Generation III":
        return Generation.iii.games
    case "Generation IV":
        return Generation.iv.games
    case "Generation V":
        return Generation.v.games
    case "Generation VI":
        return Generation.vi.games
    case "Generation VII":
        return [.sun, .moon, .ultraSun, .ultraMoon]
    case "Generation VIII":
        return Generation.viii.games
    default:
        return nil
    }
}
var abilityIndex = 0
for (abilityName, dict) in Helper.loadJSON(from: "Data/Abilities.json") as! [String: [String: String]] {
    let ability = Ability(context: moc)
    allAbilities[sanitizedName(abilityName)] = ability
    ability.name = abilityName
    ability.index = abilityIndex; abilityIndex += 1

    for key in dict.keys {
        let games = gamesForAbilityKey(key)
        let description = dict[key]?.removingQuotes().replacingOccurrences(of: "*", with: " ")
        games?.forEach { game in
            ability.setDescription(description, forGame: game)
        }
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
    }
}


// MARK: - Moves
print("--- Moves ---")
var moveDescriptionsDict = Helper.loadJSON(from: "Data/MoveDescriptions.json") as! [String: [String: String]]
moveDescriptionsDict["terrainpulse"] = [
    "Sword": "The user utilizes the power of the terrain to attack. This move's type and power changes depending on the terrain when it's used.",
    "Shield": "The user utilizes the power of the terrain to attack. This move's type and power changes depending on the terrain when it's used."
]
moveDescriptionsDict["burningjealousy"] = [
    "Sword": "The user attacks with energy from jealousy. This leaves all opposing Pokémon that have had their stats boosted during the turn with a burn.",
    "Shield": "The user attacks with energy from jealousy. This leaves all opposing Pokémon that have had their stats boosted during the turn with a burn."
]
moveDescriptionsDict["flipturn"] = [
    "Sword": "After making its attack, the user rushes back to switch places with a party Pokémon in waiting.",
    "Shield": "After making its attack, the user rushes back to switch places with a party Pokémon in waiting."
]
moveDescriptionsDict["grassyglide"] = [
    "Sword": "Gliding on the ground, the user attacks the target. This move always goes first on Grassy Terrain.",
    "Shield": "Gliding on the ground, the user attacks the target. This move always goes first on Grassy Terrain."
]
moveDescriptionsDict["risingvoltage"] = [
    "Sword": "The user attacks with electric voltage rising from the ground. This move's power doubles when the target is on Electric Terrain.",
    "Shield": "The user attacks with electric voltage rising from the ground. This move's power doubles when the target is on Electric Terrain."
]
moveDescriptionsDict["coaching"] = [
    "Sword": "The user properly coaches its ally Pokémon, boosting their Attack and Defense stats.",
    "Shield": "The user properly coaches its ally Pokémon, boosting their Attack and Defense stats."
]
moveDescriptionsDict["scorchingsands"] = [
    "Sword": "The user throws scorching sand at the target to attack. This may also leave the target with a burn.",
    "Shield": "The user throws scorching sand at the target to attack. This may also leave the target with a burn."
]
moveDescriptionsDict["dualwingbeat"] = [
    "Sword": "The user slams the target with its wings. The target is hit twice in a row.",
    "Shield": "The user slams the target with its wings. The target is hit twice in a row."
]
moveDescriptionsDict["meteorbeam"] = [
    "Sword": "In this two-turn attack, the user gathers space power and boosts its Sp. Atk stat, then attacks the target on the next turn.",
    "Shield": "In this two-turn attack, the user gathers space power and boosts its Sp. Atk stat, then attacks the target on the next turn."
]
moveDescriptionsDict["skittersmack"] = [
    "Sword": "The user skitters behind the target to attack. This also lowers the target's Sp. Atk stat.",
    "Shield": "The user skitters behind the target to attack. This also lowers the target's Sp. Atk stat."
]
moveDescriptionsDict["tripleaxel"] = [
    "Sword": "A consecutive three-kick attack that becomes more powerful with each successful hit.",
    "Shield": "A consecutive three-kick attack that becomes more powerful with each successful hit."
]
moveDescriptionsDict["corrosivegas"] = [
    "Sword": "The user surrounds everything around it with highly acidic gas and melts away items they hold.",
    "Shield": "The user surrounds everything around it with highly acidic gas and melts away items they hold."
]
moveDescriptionsDict["expandingforce"] = [
    "Sword": "The user attacks the target with its psychic power. This move's power goes up and damages all opposing Pokémon on Psychic Terrain.",
    "Shield": "The user attacks the target with its psychic power. This move's power goes up and damages all opposing Pokémon on Psychic Terrain."
]
moveDescriptionsDict["poltergeist"] = [
    "Sword": "The user attacks the target by controlling the target's item. The move fails if the target doesn't have an item.",
    "Shield": "The user attacks the target by controlling the target's item. The move fails if the target doesn't have an item."
]
moveDescriptionsDict["scaleshot"] = [
    "Sword": "The user attacks by shooting scales two to five times in a row. This move boosts the user's Speed stat but lowers its Defense stat.",
    "Shield": "The user attacks by shooting scales two to five times in a row. This move boosts the user's Speed stat but lowers its Defense stat."
]
moveDescriptionsDict["lashout"] = [
    "Sword": "The user lashes out to vent its frustration toward the target. If its stats were lowered during the turn, the power of this move is doubled.",
    "Shield": "The user lashes out to vent its frustration toward the target. If its stats were lowered during the turn, the power of this move is doubled."
]
moveDescriptionsDict["steelroller"] = [
    "Sword": "The user attacks while destroying the terrain. This move fails when the ground hasn't turned into a terrain.",
    "Shield": "The user attacks while destroying the terrain. This move fails when the ground hasn't turned into a terrain."
]
moveDescriptionsDict["mistyexplosion"] = [
    "Sword": "The user attacks everything around it and faints upon using this move. This move's power is increased on Misty Terrain.",
    "Shield": "The user attacks everything around it and faints upon using this move. This move's power is increased on Misty Terrain."
]
moveDescriptionsDict["junglehealing"] = [
    "Sword": "The user becomes one with the jungle, restoring HP and healing any status conditions of itself and its ally Pokémon in battle.",
    "Shield": "The user becomes one with the jungle, restoring HP and healing any status conditions of itself and its ally Pokémon in battle."
]
moveDescriptionsDict["shellsidearm"] = [
    "Sword": "This move inflicts physical or special damage, whichever will be more effective. This may also poison the target.",
    "Shield": "This move inflicts physical or special damage, whichever will be more effective. This may also poison the target."
]
moveDescriptionsDict["surgingstrikes"] = [
    "Sword": "The user, having mastered the Water style, strikes the target with a flowing motion three times in a row. This attack always results in a critical hit.",
    "Shield": "The user, having mastered the Water style, strikes the target with a flowing motion three times in a row. This attack always results in a critical hit."
]
moveDescriptionsDict["wickedblow"] = [
    "Sword": "The user, having mastered the Dark style, strikes the target with a fierce blow. This attack always results in a critical hit.",
    "Shield": "The user, having mastered the Dark style, strikes the target with a fierce blow. This attack always results in a critical hit."
]
for (moveName, dict) in Helper.loadJSON(from: "Data/Moves.json") as! [String: [String: String]] {
    let generationIntroduced = Generation(dictValue: dict["generationIntroduced"]!)!

    let key = sanitizedMoveName(moveName)
    var moves: [Game: Move] = [:]
    Generation.allCases
        .filter { $0 >= generationIntroduced }
        .map { $0.games }
        .flatMap { $0 }
        .forEach { game in
            let gameKey = Game.pokemonDBKey(for: game)
            guard let moveDescription = moveDescriptionsDict[key]?[gameKey] else {
                return
            }

            let move = Move(context: moc)
            move.name = moveName
            move.index = Int(dict["number"]!)!
            move.type = PokemonType(rawValue: dict["type"]!)!
            move.generationIntroduced = generationIntroduced
            move.game = game

            let moveInfo = MoveInfo(context: moc)
            move.info = moveInfo
            moveInfo.accuracy = Int(dict["accuracy"] ?? "")
            moveInfo.category = MoveCategory(dictValue: dict["category"] ?? "") ?? .varies
            moveInfo.maxPP = Int(dict["maxPP"] ?? "")
            moveInfo.power = Int(dict["power"] ?? "")
            moveInfo.pp = Int(dict["pp"] ?? "")
            moveInfo.targetAlly1 = Int(dict["targetAlly1"]!)! == 1
            moveInfo.targetAlly2 = Int(dict["targetAlly2"]!)! == 1
            moveInfo.targetEnemy1 = Int(dict["targetFoe1"]!)! == 1
            moveInfo.targetEnemy2 = Int(dict["targetFoe2"]!)! == 1
            moveInfo.targetEnemy3 = Int(dict["targetFoe3"]!)! == 1
            moveInfo.targetSelf = Int(dict["targetSelf"]!)! == 1
            moveInfo.targetDescription = dict["targetDescription"]!.removingQuotes()
            moveInfo.moveDescription = moveDescription

            moves[game] = move
    }
    allMoves[key] = moves
}


// MARK: - Machines
print("--- Machines ---")
func processMachineTSV(filename: String, game: Game, machineType: MachineType) -> [Int: Machine] {
    var machines: [Int: Machine] = [:]
    for dict in Helper.loadTSV(from: filename) {
        guard let move = getMove(forName: dict["name"]!, game: game) else { continue }
        let number = Int(dict["number"]!)!
        let machine = Machine(context: moc)
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
        pokemon.eggGroups = [dict["eggGroup1"], dict["eggGroup2"]].compactMap { $0 }.filter { !$0.isEmpty }.map { EggGroup(dictValue: $0)! }

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
let allPokedexNumbers: [[Game: PokedexNumbers]] = (0..<allPokemon.count)
    .map { _ in
        var numbers: [Game: PokedexNumbers] = [:]
        for game in Game.allCases {
            numbers[game] = PokedexNumbers(context: moc)
        }
        return numbers
}
zip(allPokemon.keys.sorted().map { allPokemon[$0]! }, allPokedexNumbers).forEach {
    for game in Game.allCases {
        $0[game]!.pokedexNumbers = $1[game]!
    }
}

func processPokedexNumberTSV(filename: String, dictKey: String, pokedexNumberKey: String) {

    func convertNumberString(_ numberString: String) -> Int { Int(numberString.replacingOccurrences(of: "#", with: ""))! }

    for dict in Helper.loadTSV(from: filename) {
        let national = convertNumberString(dict["national"]!) - 1 // OBO
        let numberString = dict[dictKey]!
        guard !numberString.isEmpty else { continue }
        let regionalNumber = convertNumberString(numberString)
        let pokedexNumbers = allPokedexNumbers[national]
        pokedexNumbers.values.forEach { $0.setValue(regionalNumber, forKey: pokedexNumberKey) }
    }
}

processPokedexNumberTSV(filename: "Research/PokedexNumbers/Alola-Table 1.tsv", dictKey: "alola", pokedexNumberKey: #keyPath(PokedexNumbers.z_alola))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/Alola-Table 1.tsv", dictKey: "melemele", pokedexNumberKey: #keyPath(PokedexNumbers.z_melemele))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/Alola-Table 1.tsv", dictKey: "akala", pokedexNumberKey: #keyPath(PokedexNumbers.z_akala))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/Alola-Table 1.tsv", dictKey: "ulaula", pokedexNumberKey: #keyPath(PokedexNumbers.z_ulaula))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/Alola-Table 1.tsv", dictKey: "poni", pokedexNumberKey: #keyPath(PokedexNumbers.z_poni))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/CentralKalos-Table 1.tsv", dictKey: "centralKalos", pokedexNumberKey: #keyPath(PokedexNumbers.z_centralKalos))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/CoastalKalos-Table 1.tsv", dictKey: "coastalKalos", pokedexNumberKey: #keyPath(PokedexNumbers.z_coastalKalos))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/CrownTundra-Table 1.tsv", dictKey: "crownTundra", pokedexNumberKey: #keyPath(PokedexNumbers.z_crownTundra))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/Galar-Table 1.tsv", dictKey: "galar", pokedexNumberKey: #keyPath(PokedexNumbers.z_galar))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/Hoenn-Table 1.tsv", dictKey: "hoenn", pokedexNumberKey: #keyPath(PokedexNumbers.z_hoenn))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/IsleOfArmor-Table 1.tsv", dictKey: "isleOfArmor", pokedexNumberKey: #keyPath(PokedexNumbers.z_isleOfArmor))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/Johto-Table 1.tsv", dictKey: "johto", pokedexNumberKey: #keyPath(PokedexNumbers.z_johto))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/Kanto-Table 1.tsv", dictKey: "kanto", pokedexNumberKey: #keyPath(PokedexNumbers.z_kanto))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/MountainKalos-Table 1.tsv", dictKey: "mountainKalos", pokedexNumberKey: #keyPath(PokedexNumbers.z_mountainKalos))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/National-Table 1.tsv", dictKey: "national", pokedexNumberKey: #keyPath(PokedexNumbers.z_national))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/NewHoenn-Table 1.tsv", dictKey: "newHoenn", pokedexNumberKey: #keyPath(PokedexNumbers.z_newHoenn))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/NewJohto-Table 1.tsv", dictKey: "newJohto", pokedexNumberKey: #keyPath(PokedexNumbers.z_newJohto))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/NewKanto-Table 1.tsv", dictKey: "kanto", pokedexNumberKey: #keyPath(PokedexNumbers.z_letsGoKanto))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/NewUnova-Table 1.tsv", dictKey: "newUnova", pokedexNumberKey: #keyPath(PokedexNumbers.z_newUnova))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/PearlSinnoh-Table 1.tsv", dictKey: "sinnoh", pokedexNumberKey: #keyPath(PokedexNumbers.z_sinnoh))
//processPokedexNumberTSV(filename: "Research/PokedexNumbers/Sinnoh-Table 1.tsv", dictKey: "sinnoh", pokedexNumberKey: #keyPath(PokedexNumbers.z_sinnoh)) // TODO: Fix if I feel like it, split to show Diamond/Pearl and Platinum separate
processPokedexNumberTSV(filename: "Research/PokedexNumbers/UltraAlola-Table 1.tsv", dictKey: "alola", pokedexNumberKey: #keyPath(PokedexNumbers.z_ultraAlola))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/UltraAlola-Table 1.tsv", dictKey: "melemele", pokedexNumberKey: #keyPath(PokedexNumbers.z_ultraMelemele))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/UltraAlola-Table 1.tsv", dictKey: "akala", pokedexNumberKey: #keyPath(PokedexNumbers.z_ultraAkala))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/UltraAlola-Table 1.tsv", dictKey: "ulaula", pokedexNumberKey: #keyPath(PokedexNumbers.z_ultraUlaula))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/UltraAlola-Table 1.tsv", dictKey: "poni", pokedexNumberKey: #keyPath(PokedexNumbers.z_ultraPoni))
processPokedexNumberTSV(filename: "Research/PokedexNumbers/Unova-Table 1.tsv", dictKey: "unova", pokedexNumberKey: #keyPath(PokedexNumbers.z_unova))


// MARK: - Pokemon Forms
print("--- Pokemon Forms ---")
for dict in Helper.loadTSV(from: "Research/PokemonForms.tsv") {
    let index = Int(dict["number"]!)!
    let game = Game(dictValue: dict["game"]!)!

    let pokemon = allPokemon[index]![game]!
    var gameForms = pokemon.forms

    let storedForm = PokemonForm(context: moc)
    storedForm.name = dict["formName"]!
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

    let baseStats = Stats(context: moc)
    baseStats.hp = Int(dict["baseHP"]!)!
    baseStats.attack = Int(dict["baseATK"]!)!
    baseStats.defense = Int(dict["baseDEF"]!)!
    baseStats.specialAttack = Int(dict["baseSATK"]!)!
    baseStats.specialDefense = Int(dict["baseSDEF"]!)!
    baseStats.speed = Int(dict["baseSPD"]!)!
    storedForm.baseStats = baseStats

    let evYield = Stats(context: moc)
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


// MARK: - Pokemon Moves
print("--- Pokemon Moves ---")
let asteriskCharacterSet = CharacterSet(charactersIn: "*")
let galarianSanitizedFormPokemon = ["Darmanitan"]
func sanitizedLevelForms(_ forms: [PokemonForm], forFormName formName: String, pokemonName: String) -> [PokemonForm] {
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
var levelLearnsetEntries: [String: LevelLearnsetEntry] = [:]
func sanitizedLevelingForms(_ forms: [PokemonForm], pokemonName: String, formFilter: String?) -> [PokemonForm] {
    guard let formFilter = formFilter else { return forms }
    if pokemonName == "Meowstic" {
        return forms.filter { $0.name.contains(formFilter) }
    } else {
        return forms.filter { $0.name == formFilter }
    }
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
            guard !pokemon.forms.isEmpty else { print("\(NumberFormatter.threeDigit.string(from: NSNumber(value: pokemon.index))!) \(pokemonName): No forms found for form name \(formFilter ?? "") in game \(game)"); continue }
            forms = sanitizedLevelingForms(forms, pokemonName: pokemonName, formFilter: formFilter)
            guard !forms.isEmpty else { print("\(pokemonName): No forms found for form name \(formFilter ?? "") in game \(game)"); continue }
            for form in forms {
                for moveDict in moveDicts {
                    let name = moveDict["name"]!
                    let level = Int(moveDict["level"]!.trimmingCharacters(in: asteriskCharacterSet))!
                    guard let move = getMove(forName: name, game: game) else {
                        continue
                    }

                    let debugKey = "\(pokemon.name) \(form.name) \(game.rawValue) \(name) \(level)"
                    guard levelLearnsetEntries[debugKey] == nil else {
                        print(debugKey)
                        print(levelLearnsetEntries[debugKey]!)
                        print(pokemon.name)
                        print(form.name)
                        print(game)
                        print(moveDict)
                        fatalError()
                    }

                    let entry = LevelLearnsetEntry(context: moc)
                    entry.level = level
                    entry.move = move
                    entry.form = form
                    levelLearnsetEntries[debugKey] = entry
                }
            }
        }
    }
}


// MARK: Machine
print("Machine")
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
            guard !pokemon.forms.isEmpty else { print("\(NumberFormatter.threeDigit.string(from: NSNumber(value: pokemon.index))!) \(pokemonName): No forms found for form name \(formFilter ?? "") in game \(game)"); continue }
            forms = sanitizedLevelingForms(forms, pokemonName: pokemonName, formFilter: formFilter)
            guard !forms.isEmpty else { print("\(pokemonName): No forms found for form name \(formFilter ?? "") in game \(game)"); continue }
            for form in forms {
                for machine in machines {
                    let machineNumber = Int(machine.trimmingCharacters(in: .uppercaseLetters))!
                    let resolvedMachine: Machine?
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
                    let entry = MachineLearnsetEntry(context: moc)
                    entry.machine = resolvedMachine!
                    entry.form = form
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
    } else {
        return name
    }
}

var breedingLearnsetEntries: [BreedLearnsetEntry] = []
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
                    }
                    .compactMap {
                        let fatherName = correctBreedingName($0)
                        let candidate = getPokemon(forName: fatherName, game: game)
                        guard !candidate.forms.isEmpty else { return nil }
                        return candidate
                    }
                for form in forms {
                    let entry = BreedLearnsetEntry(context: moc)
                    entry.form = form
                    entry.move = move
                    entry.fathers = fathers
                    breedingLearnsetEntries.append(entry)
                }
            }
        }
    }
}


// MARK: Tutoring
print("Tutoring")
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
            guard !pokemon.forms.isEmpty else { print("\(NumberFormatter.threeDigit.string(from: NSNumber(value: pokemon.index))!) \(pokemonName): No forms found for form name \(formFilter ?? "") in game \(game)"); continue }
            forms = sanitizedLevelingForms(forms, pokemonName: pokemonName, formFilter: formFilter)
            guard !forms.isEmpty else { print("\(pokemonName): No forms found for form name \(formFilter ?? "") in game \(game)"); continue }
            for form in forms {
                for moveName in moveNames {
                    guard let move = getMove(forName: moveName, game: game) else {
                        continue
                    }
                    let entry = TutorLearnsetEntry(context: moc)
                    entry.form = form
                    entry.move = move
                }
            }
        }
    }
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
func getOrMakeLocation(withName locationNameCandidate: String, regionName: String, game: Game) -> Location {
    let location: Location
    let locationName = resolveLocationName(forLocationName: locationNameCandidate, game: game)
    let resolvedRegionName = resolveRegionName(forLocationName: locationName, regionName: regionName)
    if let existingLocation = getLocation(forName: locationName, region: resolvedRegionName, game: game) {
        location = existingLocation
    } else {
        location = Location(context: moc)
        location.name = locationName
        location.region = Region(rawValue: resolvedRegionName)!
        location.game = game
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

                            let locationPokemon = LocationPokemon(context: moc)
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

                        let locationPokemon = LocationPokemon(context: moc)
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

    let locationMap = LocationMap(context: moc)
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
var bulbapediaItems = try! JSONDecoder().decode([BulbapediaItem].self, from: Helper.loadJSONData(from: "Data/BulbapediaItems.json"))

func convertGen7ItemToGen8(_ name: String) {
    let index = bulbapediaItems.firstIndex(where: { $0.name == name })!
    let existing = bulbapediaItems[index]

    var descriptions = existing.descriptions
    descriptions[Game.sword.rawValue] = descriptions[Game.ultraSun.rawValue]
    descriptions[Game.shield.rawValue] = descriptions[Game.ultraMoon.rawValue]

    var pocket = existing.pocket
    pocket["Generation VIII"] = pocket["Generation VII"]

    var prices = existing.prices
    prices[Game.sword.rawValue] = prices[Game.ultraSun.rawValue]
    prices[Game.shield.rawValue] = prices[Game.ultraMoon.rawValue]

    let modified = BulbapediaItem(
        descriptions: descriptions,
        generationIntroduced: existing.generationIntroduced,
        imageName: existing.imageName,
        name: existing.name,
        pocket: pocket,
        prices: prices)
    bulbapediaItems[index] = modified
}

["Oval Stone",
 "Dragon Scale",
 "Upgrade",
 "Dubious Disc"
    ].forEach { convertGen7ItemToGen8($0) }

for bulbapediaItem in bulbapediaItems {
    for game in Game.allCases {
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
        guard let bulbapediaItemInfo = bulbapediaItem.itemInfo(for: gameForInfo),
            !bulbapediaItem.name.lowercased().hasSuffix("berry") else { continue }

        let key = sanitizedItemName(bulbapediaItem.name, game: game)
        guard allItems[key]?[game] == nil else { continue }

        let item = Item(context: moc)
        item.name = bulbapediaItem.name
        item.game = game
        item.i_gameIndex = Int32(game.index)
        item.generationIntroduced = generationIntroduced
        item.imageName = bulbapediaItem.imageName.removingDiacritics()
        item.itemType = .item

        let info = BagItemInfo(context: moc)
        info.itemDescription = bulbapediaItemInfo.description.removingQuotes()
        info.cost = bulbapediaItemInfo.price.cost?.toNSNumber()
        info.sell = bulbapediaItemInfo.price.sell?.toNSNumber()

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

// Manual items
// For items that are now in Sword/Shield, but their individual Bulbapedia
// wiki pages haven't been updated with Sword/Shield data yet. This copies over
// the data from UltraSun.
func insertSwordShieldItem(forName name: String, game: Game) {
    let usumItem = allItems[sanitizedItemName(name, game: .ultraSun)]![.ultraSun]!

    let item = Item(context: moc)
    item.name = usumItem.name
    item.game = game
    item.i_gameIndex = Int32(game.index)
    item.generationIntroduced = usumItem.generationIntroduced
    item.imageName = usumItem.imageName
    item.itemType = usumItem.itemType

    let info = BagItemInfo(context: moc)
    info.itemDescription = usumItem.bagInfo!.itemDescription
    info.cost = usumItem.bagInfo!.cost
    info.sell = usumItem.bagInfo!.sell
    info.pocket = usumItem.bagInfo!.pocket
    item.bagInfo = info

    let key = sanitizedItemName(item.name, game: game)
    if var items = allItems[key] {
        items[game] = item
        allItems[key] = items
    } else {
        allItems[key] = [game: item]
    }
}
insertSwordShieldItem(forName: "Electirizer", game: .sword)
insertSwordShieldItem(forName: "Electirizer", game: .shield)
insertSwordShieldItem(forName: "Magmarizer", game: .sword)
insertSwordShieldItem(forName: "Magmarizer", game: .shield)

for dict in Helper.loadTSV(from: "Research/Berries.tsv") {
    let game = Game(rawValue: dict["game"]!)!
    let item = Item(context: moc)
    item.name = dict["name"]!
    item.game = game
    item.i_gameIndex = Int32(item.game.index)
    item.generationIntroduced = Generation(rawValue: Int(dict["generation"]!)!)!
    item.imageName = item.name.lowercased().replacingOccurrences(of: " ", with: "-")
    item.itemType = .berry

    let info = BerryItemInfo(context: moc)
    info.itemDescription = dict["description"]!.removingQuotes()
    info.firmness = dict["firmness"] != "" ? BerryFirmness(rawValue: dict["firmness"]!)! : nil
    info.spicy = dict["spicy"] != "" ? Int16(dict["spicy"]!)! : -1
    info.dry = dict["dry"] != "" ? Int16(dict["dry"]!)! : -1
    info.sweet = dict["sweet"] != "" ? Int16(dict["sweet"]!)! : -1
    info.bitter = dict["bitter"] != "" ? Int16(dict["bitter"]!)! : -1
    info.sour = dict["sour"] != "" ? Int16(dict["sour"]!)! : -1

    item.berryInfo = info

    let key = sanitizedItemName(item.name, game: game)
    if var items = allItems[key] {
        items[game] = item
        allItems[key] = items
    } else {
        allItems[key] = [game: item]
    }
}

allItems.keys
    .sorted()
    .enumerated()
    .forEach { i, key in
        let index = Int32(i)
        allItems[key]!.values.forEach { $0.i_nameIndex = index }
}


// MARK: - Evolutions
print("--- Evolutions ---")
var allEvolutions: [String: [Game: [Evolution]]] = [:] // family name as key
func evolutionMethod(for name: String, data: String, game: Game) -> EvolutionMethod {
    switch name {
    case "completeBattlePerformingAction":
        return .completeBattlePerformingAction(data)
    case "friendship":
        return .friendship
    case "levelUp":
        return .levelUp(Int(data)!)
    case "levelUpHoldingItem":
        return .levelUpHoldingItem(getItem(forName: data, game: game)!)
    case "levelUpInArea":
        return .levelUpInArea(data)
    case "levelUpKnowingMove":
        return .levelUpKnowingMove(getMove(forName: data, game: game)!)
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
        let item = allItems[sanitizedItemName(data, game: game)]![game]!
        return .tradeHoldingItem(item)
    case "trainerAction":
        return .trainerAction(data)
    case "useItem":
        return .useItem(getItem(forName: data, game: game)!)
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
    let gameFilter = Game(rawValue: dict["gameFilter"]!)
    let baseName = dict["baseName"]!
    let baseFormName = dict["baseFormName"]!
    let targetName = dict["targetName"]!
    let targetFormName = dict["targetFormName"]!
    let methodName = dict["methodName"]!
    let methodData = dict["methodData"]!
    let requirementName = dict["requirementName"]!
    let requirementData = dict["requirementData"]!

    let basePokemons = allPokemonByName[sanitizedName(baseName)]!
    let targetPokemons = allPokemonByName[sanitizedName(targetName)]!

    let games = gameFilter != nil ? [gameFilter!] : Array(basePokemons.keys)

    for game in games {
        let basePokemon = basePokemons[game]!
        guard let targetPokemon = targetPokemons[game] else {
            print("No target for \(basePokemon.name) in game \(game)")
            continue
        }

        guard let baseForm = baseFormName == "" ? basePokemon.forms.first : basePokemon.forms.first(where: { $0.name == baseFormName }),
            let targetForm = targetFormName == "" ? targetPokemon.forms.first : targetPokemon.forms.first(where: { $0.name == targetFormName }) else {
                continue
        }

        let evolution = Evolution(context: moc)
        evolution.familyName = familyName
        evolution.from = baseForm
        evolution.to = targetForm
        evolution.method = evolutionMethod(for: methodName, data: methodData, game: game)
        evolution.condition = evolutionCondition(for: requirementName, data: requirementData, game: game)

        let key = familyName
        if var existingEvolutions = allEvolutions[key] {
            var existingPerGame = existingEvolutions[game] ?? []
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
