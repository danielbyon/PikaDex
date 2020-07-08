////
////  PokedexEntriesTests.swift
////  DatabaseTests
////
////  Created by Daniel Byon on 1/3/20.
////  Copyright © 2020 Daniel Byon. All rights reserved.
////
//
//import XCTest
//import CoreData
////@testable import PikaDex
//
//class PokedexEntriesTests: ModelObjectBaseTestCase {
//    
//    typealias Subject = StoredPokedexEntries
//    
//    func testProperties() {
//        let sut = Subject(context: context)
//        
//        let red = "red"
//        let blue = "blue"
//        let yellow = "yellow"
//        let gold = "gold"
//        let silver = "silver"
//        let crystal = "crystal"
//        let ruby = "ruby"
//        let sapphire = "sapphire"
//        let emerald = "emerald"
//        let fireRed = "fireRed"
//        let leafGreen = "leafGreen"
//        let diamond = "diamond"
//        let pearl = "pearl"
//        let platinum = "platinum"
//        let heartGold = "heartGold"
//        let soulSilver = "soulSilver"
//        let black = "black"
//        let white = "white"
//        let black2 = "black2"
//        let white2 = "white2"
//        let x = "x"
//        let y = "y"
//        let omegaRuby = "omegaRuby"
//        let alphaSapphire = "alphaSapphire"
//        let sun = "sun"
//        let moon = "moon"
//        let ultraSun = "ultraSun"
//        let ultraMoon = "ultraMoon"
//        let sword = "sword"
//        let shield = "shield"
//        
//        sut.red = red
//        sut.blue = blue
//        sut.yellow = yellow
//        sut.gold = gold
//        sut.silver = silver
//        sut.crystal = crystal
//        sut.ruby = ruby
//        sut.sapphire = sapphire
//        sut.emerald = emerald
//        sut.fireRed = fireRed
//        sut.leafGreen = leafGreen
//        sut.diamond = diamond
//        sut.pearl = pearl
//        sut.platinum = platinum
//        sut.heartGold = heartGold
//        sut.soulSilver = soulSilver
//        sut.black = black
//        sut.white = white
//        sut.black2 = black2
//        sut.white2 = white2
//        sut.x = x
//        sut.y = y
//        sut.omegaRuby = omegaRuby
//        sut.alphaSapphire = alphaSapphire
//        sut.sun = sun
//        sut.moon = moon
//        sut.ultraSun = ultraSun
//        sut.ultraMoon = ultraMoon
//        sut.sword = sword
//        sut.shield = shield
//        
//        validateString(sut.red)
//        validateString(sut.blue)
//        validateString(sut.yellow)
//        validateString(sut.gold)
//        validateString(sut.silver)
//        validateString(sut.crystal)
//        validateString(sut.ruby)
//        validateString(sut.sapphire)
//        validateString(sut.emerald)
//        validateString(sut.fireRed)
//        validateString(sut.leafGreen)
//        validateString(sut.diamond)
//        validateString(sut.pearl)
//        validateString(sut.platinum)
//        validateString(sut.heartGold)
//        validateString(sut.soulSilver)
//        validateString(sut.black)
//        validateString(sut.white)
//        validateString(sut.black2)
//        validateString(sut.white2)
//        validateString(sut.x)
//        validateString(sut.y)
//        validateString(sut.omegaRuby)
//        validateString(sut.alphaSapphire)
//        validateString(sut.sun)
//        validateString(sut.moon)
//        validateString(sut.ultraSun)
//        validateString(sut.ultraMoon)
//        validateString(sut.sword)
//        validateString(sut.shield)
//    }
//
//    func testPropertyKeys() {
//        let sut = Subject(context: context)
//        
//        let entries = Game.allCases.map { $0.title }
//        
//        zip(Game.allCases, entries).forEach { game, entry in
//            sut.setEntry(entry, forGame: game)
//        }
//        
//        Game.allCases.forEach {
//            validateString(sut.entry(forGame: $0))
//        }
//    }
//
//}
