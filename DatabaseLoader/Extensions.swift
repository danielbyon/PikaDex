//
//  Extensions.swift
//  DatabaseLoader
//
//  Created by Daniel Byon on 1/4/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import PokedexCore
import DatabasePipelineSupport

// MARK: - Extensions
extension LevelingRate {

    init?(dictValue: String) {
        switch dictValue {
        case "Erratic": self = .erratic
        case "Fast": self = .fast
        case "Fluctuating": self = .fluctuating
        case "Medium Fast": self = .mediumFast
        case "Medium Slow": self = .mediumSlow
        case "Slow": self = .slow
        case "Unknown": self = .unknown
        default:
            return nil
        }
    }

}

extension EggGroup {

    init?(dictValue: String) {
        switch dictValue.lowercased() {
        case "amorphous": self = .amorphous
        case "bug": self = .bug
        case "ditto": self = .ditto
        case "dragon": self = .dragon
        case "fairy": self = .fairy
        case "field": self = .field
        case "flying": self = .flying
        case "grass": self = .grass
        case "human-like": self = .humanLike
        case "mineral": self = .mineral
        case "monster": self = .monster
        case "undiscovered": self = .undiscovered
        case "water 1": self = .water1
        case "water 2": self = .water2
        case "water 3": self = .water3
        default:
            return nil
        }
    }

}

extension Game {
    
    static func allGames(forLearnsetValue learnsetValue: String) -> [Game]? {
        switch learnsetValue {
        case "gen1": return Generation.i.games
        case "gen2": return Generation.ii.games
        case "gen3": return Generation.iii.games
        case "gen4": return Generation.iv.games
        case "gen5": return Generation.v.games
        case "gen6": return Generation.vi.games
        case "gen7": return Generation.vii.games
        case "gen8": return Generation.viii.games
        case "gen9": return Generation.ix.games
        case "red": return [.red]
        case "blue": return [.blue]
        case "yellow": return [.yellow]
        case "gold": return [.gold]
        case "silver": return [.silver]
        case "crystal": return [.crystal]
        case "ruby": return [.ruby]
        case "sapphire": return [.sapphire]
        case "emerald": return [.emerald]
        case "fireRed": return [.fireRed]
        case "leafGreen": return [.leafGreen]
        case "diamond": return [.diamond]
        case "pearl": return [.pearl]
        case "platinum": return [.platinum]
        case "heartGold": return [.heartGold]
        case "soulSilver": return [.soulSilver]
        case "black": return [.black]
        case "white": return [.white]
        case "black2": return [.black2]
        case "white2": return [.white2]
        case "x": return [.x]
        case "y": return [.y]
        case "xy": return [.x, .y]
        case "omegaRuby": return [.omegaRuby]
        case "alphaSapphire": return [.alphaSapphire]
        case "oras": return [.omegaRuby, .alphaSapphire]
        case "sun": return [.sun]
        case "moon": return [.moon]
        case "ultraSun": return [.ultraSun]
        case "ultraMoon": return [.ultraMoon]
        case "letsGoPikachu": return [.letsGoPikachu]
        case "letsGoEevee": return [.letsGoEevee]
        case "sword": return [.sword]
        case "shield": return [.shield]
        case "scarlet": return [.scarlet]
        case "violet": return [.violet]
        default: return nil
        }
    }

    static func allGames(forTutoringKey key: String, generationKey: String) -> [Game] {
        key.components(separatedBy: ",").compactMap { gameKey -> Game? in
            switch generationKey {
            case "gen1": return nil
            case "gen2":
                switch gameKey {
                case "C": return .crystal
                default: fatalError(gameKey)
                }
            case "gen3":
                switch gameKey {
                case "E": return .emerald
                case "FR": return .fireRed
                case "LG": return .leafGreen
                default: fatalError(gameKey)
                }
            case "gen4":
                switch gameKey {
                case "D": return .ruby
                case "P": return .sapphire
                case "Pt": return .emerald
                case "HG": return .fireRed
                case "SS": return .leafGreen
                default: fatalError(gameKey)
                }
            case "gen5":
                switch gameKey {
                case "B": return .black
                case "W": return .white
                case "B2": return .black2
                case "W2": return .white2
                default: fatalError(gameKey)
                }
            case "gen6":
                switch gameKey {
                case "X": return .x
                case "Y": return .y
                case "OR": return .omegaRuby
                case "AS": return .alphaSapphire
                default: fatalError(gameKey)
                }
            case "gen7":
                switch gameKey {
                case "S": return .sun
                case "M": return .moon
                case "US": return .ultraSun
                case "UM": return .ultraMoon
                case "LGP": return .letsGoPikachu
                case "LGE": return .letsGoEevee
                default: fatalError(gameKey)
                }
            case "gen8":
                switch gameKey {
                case "Sw": return .sword
                case "Sh": return .shield
                case "S", "M", "US", "UM", "LGP", "LGE": return nil
                default: fatalError(gameKey)
                }
            case "gen9":
                switch gameKey {
                case "S": return .scarlet
                case "V": return .violet
                default: fatalError(gameKey)
                }
            default: fatalError(generationKey)
            }
        }
    }

    static func pokemonDBKey(for game: Game) -> String {
        switch game {
        case .red: return "Gold"
        case .blue: return "Silver"
        case .yellow: return "Crystal"
        case .gold: return "Gold"
        case .silver: return "Silver"
        case .crystal: return "Crystal"
        case .ruby: return "Ruby"
        case .sapphire: return "Sapphire"
        case .emerald: return "Emerald"
        case .fireRed: return "FireRed"
        case .leafGreen: return "LeafGreen"
        case .diamond: return "Diamond"
        case .pearl: return "Pearl"
        case .platinum: return "Platinum"
        case .heartGold: return "HeartGold"
        case .soulSilver: return "SoulSilver"
        case .black: return "Black"
        case .white: return "White"
        case .black2: return "Black 2"
        case .white2: return "White 2"
        case .x: return "X"
        case .y: return "Y"
        case .omegaRuby: return "O.Ruby"
        case .alphaSapphire: return "A.Sapphire"
        case .sun: return "Sun"
        case .moon: return "Moon"
        case .ultraSun: return "Ultra Sun"
        case .ultraMoon: return "Ultra Moon"
        case .letsGoPikachu: return "L.G. Pikachu"
        case .letsGoEevee: return "L.G. Eevee"
        case .sword: return "Sword"
        case .shield: return "Shield"
        case .brilliantDiamond: return "B.Diamond"
        case .shiningPearl: return "S.Pearl"
            // TODO: Check in the future to see if they have Arceus-specific descriptions
        case .legendsArceus: return pokemonDBKey(for: .sword)
        case .scarlet: return "Scarlet"
        case .violet: return "Violet"
        case .national: return "Sword"
        }
    }

    init(locationAbbreviation abbreviation: String, generation: Generation) {
        switch generation {
        case .i:
            switch abbreviation {
            case "R":
                self = .red
            case "B":
                self = .blue
            case "Y":
                self = .yellow
            default:
                fatalError()
            }
        case .ii:
            switch abbreviation {
            case "G":
                self = .gold
            case "S":
                self = .silver
            case "C":
                self = .crystal
            default:
                fatalError()
            }
        case .iii:
            switch abbreviation {
            case "R":
                self = .ruby
            case "S":
                self = .sapphire
            case "E":
                self = .emerald
            case "FR":
                self = .fireRed
            case "LG":
                self = .leafGreen
            default:
                fatalError()
            }
        case .iv:
            switch abbreviation {
            case "D":
                self = .diamond
            case "P":
                self = .pearl
            case "Pt":
                self = .platinum
            case "HG":
                self = .heartGold
            case "SS":
                self = .soulSilver
            default:
                fatalError()
            }
        case .v:
            switch abbreviation {
            case "B":
                self = .black
            case "W":
                self = .white
            case "B2":
                self = .black2
            case "W2":
                self = .white2
            default:
                fatalError()
            }
        case .vi:
            switch abbreviation {
            case "X":
                self = .x
            case "Y":
                self = .y
            case "OR":
                self = .omegaRuby
            case "AS":
                self = .alphaSapphire
            default:
                fatalError()
            }
        case .vii:
            switch abbreviation {
            case "S":
                self = .sun
            case "M":
                self = .moon
            case "US":
                self = .ultraSun
            case "UM":
                self = .ultraMoon
            case "LGP":
                self = .letsGoPikachu
            case "LGE":
                self = .letsGoEevee
            default:
                fatalError()
            }
        case .viii:
            switch abbreviation {
            case "Sw":
                self = .sword
            case "Sh":
                self = .shield
            case "BD":
                self = .brilliantDiamond
            case "SP":
                self = .shiningPearl
            case "LA":
                self = .legendsArceus
            default:
                fatalError()
            }
        case .ix:
            switch abbreviation {
            case "S":
                self = .scarlet
            case "V":
                self = .violet
            default:
                fatalError()
            }
        case .all:
            self = .national
        }
    }

}

extension Generation {

    init?(dictValue: String) {
        switch dictValue {
        case "Generation I": self = .i
        case "Generation II": self = .ii
        case "Generation III": self = .iii
        case "Generation IV": self = .iv
        case "Generation V": self = .v
        case "Generation VI": self = .vi
        case "Generation VII": self = .vii
        case "Generation VIII": self = .viii
        case "Generation IX": self = .ix
        case "National": self = .all
        default: return nil
        }
    }

    var dictValue: String {
        switch self {
        case .i: return "Generation I"
        case .ii: return "Generation II"
        case .iii: return "Generation III"
        case .iv: return "Generation IV"
        case .v: return "Generation V"
        case .vi: return "Generation VI"
        case .vii: return "Generation VII"
        case .viii: return "Generation VIII"
        case .ix: return "Generation IX"
        case .all: return "National"
        }
    }

}

extension MoveCategory {

    init?(dictValue: String) {
        self.init(rawValue: dictValue.lowercased())
    }

}

extension Game {

    init?(title: String) {
        switch title {
        case "Red": self = .red
        case "Blue": self = .blue
        case "Yellow": self = .yellow
        case "Gold": self = .gold
        case "Silver": self = .silver
        case "Crystal": self = .crystal
        case "Ruby": self = .ruby
        case "Sapphire": self = .sapphire
        case "Emerald": self = .emerald
        case "FireRed": self = .fireRed
        case "LeafGreen": self = .leafGreen
        case "Diamond": self = .diamond
        case "Pearl": self = .pearl
        case "Platinum": self = .platinum
        case "HeartGold": self = .heartGold
        case "SoulSilver": self = .soulSilver
        case "Black": self = .black
        case "White": self = .white
        case "Black 2": self = .black2
        case "White 2": self = .white2
        case "X": self = .x
        case "Y": self = .y
        case "Omega Ruby": self = .omegaRuby
        case "Alpha Sapphire": self = .alphaSapphire
        case "Sun": self = .sun
        case "Moon": self = .moon
        case "Ultra Sun": self = .ultraSun
        case "Ultra Moon": self = .ultraMoon
        case "Let's Go Pikachu": self = .letsGoPikachu
        case "Let's Go Eevee": self = .letsGoEevee
        case "Sword": self = .sword
        case "Shield": self = .shield
        case "Brilliant Diamond": self = .brilliantDiamond
        case "Shining Pearl": self = .shiningPearl
        case "Legends: Arceus": self = .legendsArceus
        case "Scarlet": self = .scarlet
        case "Violet": self = .violet
        case "National": self = .national
        default: return nil
        }
    }

    init?(dictValue: String) {
        switch dictValue.lowercased() {
        case "red": self = .red
        case "blue": self = .blue
        case "yellow": self = .yellow
        case "gold": self = .gold
        case "silver": self = .silver
        case "crystal": self = .crystal
        case "ruby": self = .ruby
        case "sapphire": self = .sapphire
        case "emerald": self = .emerald
        case "firered": self = .fireRed
        case "leafgreen": self = .leafGreen
        case "diamond": self = .diamond
        case "pearl": self = .pearl
        case "platinum": self = .platinum
        case "heartgold": self = .heartGold
        case "soulsilver": self = .soulSilver
        case "black": self = .black
        case "white": self = .white
        case "black 2": self = .black2
        case "white 2": self = .white2
        case "x": self = .x
        case "y": self = .y
        case "omega ruby": self = .omegaRuby
        case "alpha sapphire": self = .alphaSapphire
        case "sun": self = .sun
        case "moon": self = .moon
        case "ultra sun": self = .ultraSun
        case "ultra moon": self = .ultraMoon
        case "let's go pikachu": self = .letsGoPikachu
        case "let's go eevee": self = .letsGoEevee
        case "sword": self = .sword
        case "shield": self = .shield
        case "brilliant diamond": self = .brilliantDiamond
        case "shining pearl": self = .shiningPearl
        case "legends: arceus": self = .legendsArceus
        case "scarlet": self = .scarlet
        case "violet": self = .violet
        case "national": self = .national
        default: return nil
        }
    }

    init(pokemonDBKey: String) {
        switch pokemonDBKey {
        case "Red": self = .red
        case "Blue": self = .blue
        case "Yellow": self = .yellow
        case "Gold": self = .gold
        case "Silver": self = .silver
        case "Crystal": self = .crystal
        case "Ruby": self = .ruby
        case "Sapphire": self = .sapphire
        case "Emerald": self = .emerald
        case "FireRed": self = .fireRed
        case "LeafGreen": self = .leafGreen
        case "Diamond": self = .diamond
        case "Pearl": self = .pearl
        case "Platinum": self = .platinum
        case "HeartGold": self = .heartGold
        case "SoulSilver": self = .soulSilver
        case "Black": self = .black
        case "White": self = .white
        case "Black 2": self = .black2
        case "White 2": self = .white2
        case "X": self = .x
        case "Y": self = .y
        case "Omega Ruby": self = .omegaRuby
        case "O.Ruby": self = .omegaRuby
        case "Alpha Sapphire": self = .alphaSapphire
        case "A.Sapphire": self = .alphaSapphire
        case "Sun": self = .sun
        case "Moon": self = .moon
        case "Ultra Sun": self = .ultraSun
        case "Ultra Moon": self = .ultraMoon
        case "Let's Go, Pikachu!": self = .letsGoPikachu
        case "Let's Go, Eevee!": self = .letsGoEevee
        case "Sword": self = .sword
        case "Shield": self = .shield
        case "Brilliant Diamond": self = .brilliantDiamond
        case "B.Diamond": self = .brilliantDiamond
        case "Shining Pearl": self = .shiningPearl
        case "S.Pearl": self = .shiningPearl
        case "Legends: Arceus": self = .legendsArceus
        case "Scarlet": self = .scarlet
        case "Violet": self = .violet
        case "National": self = .national
        default:
            fatalError()
        }
    }

}

extension Int {

    func toNSNumber() -> NSNumber {
        NSNumber(value: self)
    }

}

extension Double {

    func toNSNumber() -> NSNumber {
        NSNumber(value: self)
    }

}
