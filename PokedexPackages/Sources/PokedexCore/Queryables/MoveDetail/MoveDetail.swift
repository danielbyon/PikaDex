//
//  MoveDetail.swift
//  
//
//  Created by Daniel Byon on 9/29/22.
//

import Foundation

public struct MoveDetail: Queryable {

    public typealias Filter = MoveDetailFilter

    public let name: String
    public let game: Game
    public let index: Int

    public init(result: StoredMove) {
        self.name = result.name
        self.game = result.game
        self.index = result.index
    }

    public init(
        name: String,
        game: Game,
        index: Int
    ) {
        self.name = name
        self.game = game
        self.index = index
    }

}

extension MoveDetail: Codable { }

extension MoveDetail: Hashable { }
