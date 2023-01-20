//
//  LearnsetLevelEntry.swift
//  
//
//  Created by Daniel Byon on 10/3/22.
//

import Foundation

public struct LearnsetLevelEntry: Queryable {

    public typealias Filter = LearnsetLevelEntryFilter

    public let level: Int
    public let form: LearnsetPokemonForm
    public let move: Move

    public init(result: Filter.ResultType) {
        level = result.level
        form = .init(result: result.form)
        move = .init(result: result.move)
    }

    init(
        level: Int,
        form: LearnsetPokemonForm,
        move: Move
    ) {
        self.level = level
        self.form = form
        self.move = move
    }

}

extension LearnsetLevelEntry: Codable { }

extension LearnsetLevelEntry: Hashable { }

extension LearnsetLevelEntry: Identifiable {

    public var id: String { "\(level) \(form.game) \(form.index) \(form.formIndex) \(move.index)" }

}
