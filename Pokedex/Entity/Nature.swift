//
//  Nature.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/23/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

struct Nature {

    let name: String
    let increasedStat: StatType?
    let decreasedStat: StatType?
    let likedFlavor: Flavor?
    let dislikedFlavor: Flavor?

}

extension Nature: Comparable {

    static func < (lhs: Nature, rhs: Nature) -> Bool {
        lhs.name < rhs.name
    }

}

extension Nature: Equatable {

    static func == (lhs: Nature, rhs: Nature) -> Bool {
        lhs.name == rhs.name
            && lhs.increasedStat == rhs.increasedStat
            && lhs.decreasedStat == rhs.decreasedStat
            && lhs.likedFlavor == rhs.likedFlavor
            && lhs.dislikedFlavor == rhs.dislikedFlavor
    }

}

extension Nature: Identifiable {

    var id: String { name }

}

extension Nature {

    static let all: [Nature] = [
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

    static subscript(name: String) -> Nature? { all.first { $0.name == name } }

    static let adamant = Nature(
        name: "Adamant",
        increasedStat: .attack,
        decreasedStat: .specialAttack,
        likedFlavor: .spicy,
        dislikedFlavor: .dry)

    static let bashful = Nature(
        name: "Bashful",
        increasedStat: nil,
        decreasedStat: nil,
        likedFlavor: nil,
        dislikedFlavor: nil)

    static let bold = Nature(
        name: "Bold",
        increasedStat: .defense,
        decreasedStat: .attack,
        likedFlavor: .sour,
        dislikedFlavor: .spicy)

    static let brave = Nature(
        name: "Brave",
        increasedStat: .attack,
        decreasedStat: .speed,
        likedFlavor: .spicy,
        dislikedFlavor: .sweet)

    static let calm = Nature(
        name: "Calm",
        increasedStat: .specialDefense,
        decreasedStat: .attack,
        likedFlavor: .bitter,
        dislikedFlavor: .spicy)

    static let careful = Nature(
        name: "Careful",
        increasedStat: .specialDefense,
        decreasedStat: .specialAttack,
        likedFlavor: .bitter,
        dislikedFlavor: .dry)

    static let docile = Nature(
        name: "Docile",
        increasedStat: nil,
        decreasedStat: nil,
        likedFlavor: nil,
        dislikedFlavor: nil)

    static let gentle = Nature(
        name: "Gentle",
        increasedStat: .specialDefense,
        decreasedStat: .defense,
        likedFlavor: .bitter,
        dislikedFlavor: .sour)

    static let hardy = Nature(
        name: "Hardy",
        increasedStat: nil,
        decreasedStat: nil,
        likedFlavor: nil,
        dislikedFlavor: nil)

    static let hasty = Nature(
        name: "Hasty",
        increasedStat: .speed,
        decreasedStat: .defense,
        likedFlavor: .sweet,
        dislikedFlavor: .sour)

    static let impish = Nature(
        name: "Impish",
        increasedStat: .defense,
        decreasedStat: .specialAttack,
        likedFlavor: .sour,
        dislikedFlavor: .dry)

    static let jolly = Nature(
        name: "Jolly",
        increasedStat: .speed,
        decreasedStat: .specialAttack,
        likedFlavor: .sweet,
        dislikedFlavor: .dry)

    static let lax = Nature(
        name: "Lax",
        increasedStat: .defense,
        decreasedStat: .specialDefense,
        likedFlavor: .sour,
        dislikedFlavor: .bitter)

    static let lonely = Nature(
        name: "Lonely",
        increasedStat: .attack,
        decreasedStat: .defense,
        likedFlavor: .spicy,
        dislikedFlavor: .sour)

    static let mild = Nature(
        name: "Mild",
        increasedStat: .specialAttack,
        decreasedStat: .defense,
        likedFlavor: .dry,
        dislikedFlavor: .sour)

    static let modest = Nature(
        name: "Modest",
        increasedStat: .specialAttack,
        decreasedStat: .attack,
        likedFlavor: .dry,
        dislikedFlavor: .spicy)

    static let naive = Nature(
        name: "Naïve",
        increasedStat: .speed,
        decreasedStat: .specialDefense,
        likedFlavor: .sweet,
        dislikedFlavor: .bitter)

    static let naughty = Nature(
        name: "Naughty",
        increasedStat: .attack,
        decreasedStat: .specialDefense,
        likedFlavor: .spicy,
        dislikedFlavor: .bitter)

    static let quiet = Nature(
        name: "Quiet",
        increasedStat: .specialAttack,
        decreasedStat: .speed,
        likedFlavor: .dry,
        dislikedFlavor: .sweet)

    static let quirky = Nature(
        name: "Quirky",
        increasedStat: nil,
        decreasedStat: nil,
        likedFlavor: nil,
        dislikedFlavor: nil)

    static let rash = Nature(
        name: "Rash",
        increasedStat: .specialAttack,
        decreasedStat: .specialDefense,
        likedFlavor: .dry,
        dislikedFlavor: .bitter)

    static let relaxed = Nature(
        name: "Relaxed",
        increasedStat: .defense,
        decreasedStat: .speed,
        likedFlavor: .sour,
        dislikedFlavor: .sweet)

    static let sassy = Nature(
        name: "Sassy",
        increasedStat: .specialDefense,
        decreasedStat: .speed,
        likedFlavor: .bitter,
        dislikedFlavor: .sweet)

    static let serious = Nature(
        name: "Serious",
        increasedStat: nil,
        decreasedStat: nil,
        likedFlavor: nil,
        dislikedFlavor: nil)

    static let timid = Nature(
        name: "Timid",
        increasedStat: .speed,
        decreasedStat: .attack,
        likedFlavor: .sweet,
        dislikedFlavor: .spicy)

}
