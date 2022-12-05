//
//  LearnsetBreedingEntry.swift
//  
//
//  Created by Daniel Byon on 10/3/22.
//

import Foundation

public struct LearnsetBreedingEntry: Queryable {

    public typealias Filter = LearnsetBreedingEntryFilter

    public let form: LearnsetPokemonForm
    public let move: Move
    public let fathers: [LearnsetBreedingFather]

    public init(
        form: LearnsetPokemonForm,
        move: Move,
        fathers: [LearnsetBreedingFather]
    ) {
        self.form = form
        self.move = move
        self.fathers = fathers
    }

    public init(result: StoredLearnsetEntry) {
        self.form = .init(result: result.form)
        self.move = .init(result: result.move)
        self.fathers = result.fathers.map(LearnsetBreedingFather.init)
    }

}

extension LearnsetBreedingEntry: Codable { }

extension LearnsetBreedingEntry: Hashable { }

extension LearnsetBreedingEntry: Identifiable {

    public var id: String { "\(form.game) \(form.index) \(form.formIndex) \(move.index) \(fathers.map(\.name))" }

}
