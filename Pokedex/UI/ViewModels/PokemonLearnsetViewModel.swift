//
//  PokemonLearnsetViewModel.swift
//  Pokedex
//
//  Created by Daniel Byon on 1/26/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import UIKit

struct PokemonLearnsetViewModel {
    let move: Move
    let detailText: String?
}

extension PokemonLearnsetViewModel: Identifiable {

    var id: String { "\(move.name) \(detailText ?? "")" }

}

extension PokemonLearnsetViewModel {

    init(learnsetEntry: LearnsetEntry) {
        if let level = learnsetEntry as? LevelLearnsetEntry {
            self.init(levelLearnsetEntry: level)
        } else if let level = learnsetEntry as? MachineLearnsetEntry {
            self.init(machineLearnsetEntry: level)
        } else if let level = learnsetEntry as? BreedLearnsetEntry {
            self.init(breedLearnsetEntry: level)
        } else if let level = learnsetEntry as? TutorLearnsetEntry {
            self.init(tutorLearnsetEntry: level)
        } else {
            fatalError()
        }
    }

    init(levelLearnsetEntry entry: LevelLearnsetEntry) {
        let level = entry.level
        let detailText = level >= 0 ? "Lv. \(NumberFormatter.twoDigit.string(from: NSNumber(value: level))!)" : "Evo."
        self.init(
            move: entry.move,
            detailText: detailText)
    }

    init(machineLearnsetEntry entry: MachineLearnsetEntry) {
        let machine = entry.machine
        let machineType = machine.type
        let move = machine.move
        let detailText = "\(machineType.title) \(NumberFormatter.twoDigit.string(from: NSNumber(value: machine.number))!)"
        self.init(
            move: move,
            detailText: detailText)
    }

    init(breedLearnsetEntry entry: BreedLearnsetEntry) {
        let detailText = entry.fathers
            .compactMap { $0.name }
            .sorted()
            .joined(separator: ", ")
        self.init(
            move: entry.move,
            detailText: detailText)
    }

    init(tutorLearnsetEntry entry: TutorLearnsetEntry) {
        self.init(
            move: entry.move,
            detailText: nil)
    }

}
