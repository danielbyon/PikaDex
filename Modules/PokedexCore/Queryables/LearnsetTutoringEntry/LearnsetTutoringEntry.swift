//
//  LearnsetTutoringEntry.swift
//  
//
//  Created by Daniel Byon on 10/3/22.
//

import Foundation

public struct LearnsetTutoringEntry: Queryable {

    public typealias Filter = LearnsetTutoringEntryFilter

    public let form: LearnsetPokemonForm
    public let move: Move

    public init(
        form: LearnsetPokemonForm,
        move: Move
    ) {
        self.form = form
        self.move = move
    }

    public init(result: StoredLearnsetEntry) {
        self.form = .init(result: result.form)
        self.move = .init(result: result.move)
    }

}

extension LearnsetTutoringEntry: Codable { }

extension LearnsetTutoringEntry: Hashable { }

extension LearnsetTutoringEntry: Identifiable {

    public var id: String { "\(form.game) \(form.index) \(form.formIndex) \(move.index)" }

}
