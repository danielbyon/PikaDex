//
//  LearnsetMachineEntry.swift
//  
//
//  Created by Daniel Byon on 10/3/22.
//

import Foundation

public struct LearnsetMachineEntry: Queryable {

    public typealias Filter = LearnsetMachineEntryFilter

    public let form: LearnsetPokemonForm
    public let number: Int
    public let type: MachineType
    public let move: Move

    public init(
        form: LearnsetPokemonForm,
        number: Int,
        type: MachineType,
        move: Move
    ) {
        self.form = form
        self.number = number
        self.type = type
        self.move = move
    }

    public init(result: StoredLearnsetEntry) {
        self.form = .init(result: result.form)
        self.number = result.machine!.number
        self.type = result.machine!.type
        self.move = .init(result: result.machine!.move)
    }
    
}

extension LearnsetMachineEntry: Codable { }

extension LearnsetMachineEntry: Hashable { }

extension LearnsetMachineEntry: Identifiable {

    public var id: String { "\(form.game) \(form.index) \(form.formIndex) \(number) \(type) \(move.index)" }

}
