//
//  CaptureMethod.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/2/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

public enum CaptureMethod: String {

    case berryPiles = "Berry Piles"
    case flying = "Flying"
    case gift = "Gift"
    case goodRod = "Good Rod"
    case headbutt = "Headbutt"
    case headbuttSpecial = "Headbutt (Special)"
    case honeyTree = "Honey Tree"
    case interact = "Interact"
    case oldRod = "Old Rod"
    case pokeRadar = "PokeRadar"
    case rockSmash = "Rock Smash"
    case shakingTrees = "Shaking Trees"
    case superRod = "Super Rod"
    case surfing = "Surfing"
    case trade = "Trade"
    case walking = "Walking"
    case walkingOverworld = "Walking - Overworld"
    case wildDen = "Wild Den"

}

extension CaptureMethod: Codable { }

extension CaptureMethod: Hashable { }
