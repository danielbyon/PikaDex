//
//  Nature.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/23/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

public struct Nature {

    public let name: String
    public let increasedStat: StatType?
    public let decreasedStat: StatType?
    public let likedFlavor: Flavor?
    public let dislikedFlavor: Flavor?

}

extension Nature: Comparable {

    public static func < (lhs: Nature, rhs: Nature) -> Bool {
        lhs.name < rhs.name
    }

}

extension Nature: Equatable {

    public static func == (lhs: Nature, rhs: Nature) -> Bool {
        lhs.name == rhs.name
            && lhs.increasedStat == rhs.increasedStat
            && lhs.decreasedStat == rhs.decreasedStat
            && lhs.likedFlavor == rhs.likedFlavor
            && lhs.dislikedFlavor == rhs.dislikedFlavor
    }

}

extension Nature: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(increasedStat)
        hasher.combine(decreasedStat)
        hasher.combine(likedFlavor)
        hasher.combine(dislikedFlavor)
    }

}

extension Nature: Identifiable {

    public var id: String { name }

}

extension Nature {

    public static let all: [Nature] = [
        .adamant,
        .bashful,
        .bold,
        .brave,
        .calm,
        .careful,
        .docile,
        .gentle,
        .hardy,
        .hasty,
        .impish,
        .jolly,
        .lax,
        .lonely,
        .mild,
        .modest,
        .naive,
        .naughty,
        .quiet,
        .quirky,
        .rash,
        .relaxed,
        .sassy,
        .serious,
        .timid
    ]

    public static subscript(name: String) -> Nature? { all.first { $0.name == name } }

    public static let adamant = Nature(
        name: "Adamant",
        increasedStat: .attack,
        decreasedStat: .specialAttack,
        likedFlavor: .spicy,
        dislikedFlavor: .dry)

    public static let bashful = Nature(
        name: "Bashful",
        increasedStat: nil,
        decreasedStat: nil,
        likedFlavor: nil,
        dislikedFlavor: nil)

    public static let bold = Nature(
        name: "Bold",
        increasedStat: .defense,
        decreasedStat: .attack,
        likedFlavor: .sour,
        dislikedFlavor: .spicy)

    public static let brave = Nature(
        name: "Brave",
        increasedStat: .attack,
        decreasedStat: .speed,
        likedFlavor: .spicy,
        dislikedFlavor: .sweet)

    public static let calm = Nature(
        name: "Calm",
        increasedStat: .specialDefense,
        decreasedStat: .attack,
        likedFlavor: .bitter,
        dislikedFlavor: .spicy)

    public static let careful = Nature(
        name: "Careful",
        increasedStat: .specialDefense,
        decreasedStat: .specialAttack,
        likedFlavor: .bitter,
        dislikedFlavor: .dry)

    public static let docile = Nature(
        name: "Docile",
        increasedStat: nil,
        decreasedStat: nil,
        likedFlavor: nil,
        dislikedFlavor: nil)

    public static let gentle = Nature(
        name: "Gentle",
        increasedStat: .specialDefense,
        decreasedStat: .defense,
        likedFlavor: .bitter,
        dislikedFlavor: .sour)

    public static let hardy = Nature(
        name: "Hardy",
        increasedStat: nil,
        decreasedStat: nil,
        likedFlavor: nil,
        dislikedFlavor: nil)

    public static let hasty = Nature(
        name: "Hasty",
        increasedStat: .speed,
        decreasedStat: .defense,
        likedFlavor: .sweet,
        dislikedFlavor: .sour)

    public static let impish = Nature(
        name: "Impish",
        increasedStat: .defense,
        decreasedStat: .specialAttack,
        likedFlavor: .sour,
        dislikedFlavor: .dry)

    public static let jolly = Nature(
        name: "Jolly",
        increasedStat: .speed,
        decreasedStat: .specialAttack,
        likedFlavor: .sweet,
        dislikedFlavor: .dry)

    public static let lax = Nature(
        name: "Lax",
        increasedStat: .defense,
        decreasedStat: .specialDefense,
        likedFlavor: .sour,
        dislikedFlavor: .bitter)

    public static let lonely = Nature(
        name: "Lonely",
        increasedStat: .attack,
        decreasedStat: .defense,
        likedFlavor: .spicy,
        dislikedFlavor: .sour)

    public static let mild = Nature(
        name: "Mild",
        increasedStat: .specialAttack,
        decreasedStat: .defense,
        likedFlavor: .dry,
        dislikedFlavor: .sour)

    public static let modest = Nature(
        name: "Modest",
        increasedStat: .specialAttack,
        decreasedStat: .attack,
        likedFlavor: .dry,
        dislikedFlavor: .spicy)

    public static let naive = Nature(
        name: "Naïve",
        increasedStat: .speed,
        decreasedStat: .specialDefense,
        likedFlavor: .sweet,
        dislikedFlavor: .bitter)

    public static let naughty = Nature(
        name: "Naughty",
        increasedStat: .attack,
        decreasedStat: .specialDefense,
        likedFlavor: .spicy,
        dislikedFlavor: .bitter)

    public static let quiet = Nature(
        name: "Quiet",
        increasedStat: .specialAttack,
        decreasedStat: .speed,
        likedFlavor: .dry,
        dislikedFlavor: .sweet)

    public static let quirky = Nature(
        name: "Quirky",
        increasedStat: nil,
        decreasedStat: nil,
        likedFlavor: nil,
        dislikedFlavor: nil)

    public static let rash = Nature(
        name: "Rash",
        increasedStat: .specialAttack,
        decreasedStat: .specialDefense,
        likedFlavor: .dry,
        dislikedFlavor: .bitter)

    public static let relaxed = Nature(
        name: "Relaxed",
        increasedStat: .defense,
        decreasedStat: .speed,
        likedFlavor: .sour,
        dislikedFlavor: .sweet)

    public static let sassy = Nature(
        name: "Sassy",
        increasedStat: .specialDefense,
        decreasedStat: .speed,
        likedFlavor: .bitter,
        dislikedFlavor: .sweet)

    public static let serious = Nature(
        name: "Serious",
        increasedStat: nil,
        decreasedStat: nil,
        likedFlavor: nil,
        dislikedFlavor: nil)

    public static let timid = Nature(
        name: "Timid",
        increasedStat: .speed,
        decreasedStat: .attack,
        likedFlavor: .sweet,
        dislikedFlavor: .spicy)

}
