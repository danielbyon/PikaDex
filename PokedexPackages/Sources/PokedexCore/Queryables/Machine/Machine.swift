//
//  Machine.swift
//  
//
//  Created by Daniel Byon on 10/21/22.
//

import Foundation

public struct Machine: Queryable {

    public typealias Filter = MachineFilter

    public let number: Int
    public let game: Game
    public let type: MachineType
    public let move: Move

    public init(result: StoredMachine) {
        number = result.number
        game = result.game
        type = result.type
        move = .init(result: result.move)
    }

    public init(
        number: Int,
        game: Game,
        type: MachineType,
        move: Move
    ) {
        self.number = number
        self.game = game
        self.type = type
        self.move = move
    }

}
