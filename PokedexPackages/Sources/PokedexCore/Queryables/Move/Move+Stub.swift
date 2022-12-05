//
//  Move+Stub.swift
//  
//
//  Created by Daniel Byon on 10/3/22.
//

import Foundation

extension Move {

    public static var defenseCurl: Move {
        .init(
            name: "Defense Curl",
            game: .sword,
            generationIntroduced: 1,
            index: 1,
            type: .normal,
            category: .status,
            bulbapediaURL: URL(string: "http://bulbapedia.bulbagarden.net/wiki/Defense_Curl_(move)")!,
            pokemonDBURL: URL(string: "https://pokemondb.net/move/defense-curl")!,
            accuracy: nil,
            maxPP: 64,
            moveDescription: "The user curls up to conceal weak spots and raise its Defense stat.",
            power: nil,
            pp: 40,
            priority: 0,
            targetAlly1: false,
            targetAlly2: false,
            targetDescription: "Affects the user",
            targetEnemy1: false,
            targetEnemy2: false,
            targetEnemy3: false,
            targetSelf: true
        )
    }

    public static var psybeam: Move {
        .init(
            name: "Psybeam",
            game: .sword,
            generationIntroduced: 1,
            index: 2,
            type: .psychic,
            category: .special,
            bulbapediaURL: URL(string: "http://bulbapedia.bulbagarden.net/wiki/Psybeam_(move)")!,
            pokemonDBURL: URL(string: "https://pokemondb.net/move/psybeam")!,
            accuracy: 100,
            maxPP: 32,
            moveDescription: "The target is attacked with a peculiar ray. This may also leave the target confused.",
            power: 65,
            pp: 20,
            priority: 0,
            targetAlly1: false,
            targetAlly2: false,
            targetDescription: "May affect anyone adjacent to the user",
            targetEnemy1: true,
            targetEnemy2: true,
            targetEnemy3: false,
            targetSelf: false
        )
    }

    public static var seismicToss: Move {
        .init(
            name: "Seismic Toss",
            game: .sword,
            generationIntroduced: 1,
            index: 3,
            type: .fighting,
            category: .physical,
            bulbapediaURL: URL(string: "http://bulbapedia.bulbagarden.net/wiki/Seismic_Toss_(move)")!,
            pokemonDBURL: URL(string: "https://pokemondb.net/move/seismic-toss")!,
            accuracy: 100,
            maxPP: 32,
            moveDescription: "The target is thrown using the power of gravity. It inflicts damage equal to the user’s level.",
            power: nil,
            pp: 20,
            priority: 0,
            targetAlly1: false,
            targetAlly2: false,
            targetDescription: "May affect anyone adjacent to the user",
            targetEnemy1: true,
            targetEnemy2: true,
            targetEnemy3: false,
            targetSelf: false
        )
    }

}
