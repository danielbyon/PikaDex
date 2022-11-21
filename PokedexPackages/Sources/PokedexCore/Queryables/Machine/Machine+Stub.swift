//
//  Machine+Stub.swift
//  
//
//  Created by Daniel Byon on 10/22/22.
//

import Foundation

extension Machine {

    public static var tm01: Machine {
        .init(
            number: 1,
            game: .sword,
            type: .tm,
            move: .init(
                name: "Mega Kick",
                game: .sword,
                generationIntroduced: 1,
                index: 1,
                type: .normal,
                category: .physical,
                bulbapediaURL: URL(string: "http://bulbapedia.bulbagarden.net/wiki/Mega_Kick_(move)")!,
                pokemonDBURL: URL(string: "https://pokemondb.net/move/mega-kick")!,
                moveDescription: "The target is attacked by a kick launched with muscle-packed power.",
                priority: 0,
                targetAlly1: true,
                targetAlly2: false,
                targetDescription: "Targets a single adjacent Pokémon.",
                targetEnemy1: true,
                targetEnemy2: true,
                targetEnemy3: false,
                targetSelf: false
            )
        )
    }

}
