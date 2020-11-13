//
//  MoveLearnsetViewModel.swift
//  Pokedex
//
//  Created by Daniel Byon on 2/27/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import UIKit

struct MoveLearnsetViewModel {
    let text: String
    let subtext: String?
    let detailText: String?
    let image: UIImage?
    let pokemonForm: PokemonForm
}

extension MoveLearnsetViewModel: Identifiable {

    var id: String { "\(text) \(pokemonForm.pokemon.name) \(subtext ?? "") \(detailText ?? "")" }

}

extension MoveLearnsetViewModel {

    init?(learnsetEntry: LearnsetEntry) {
        if let level = learnsetEntry as? LevelLearnsetEntry {
            self.init(levelLearnsetEntry: level)
        } else if let level = learnsetEntry as? MachineLearnsetEntry {
            self.init(machineLearnsetEntry: level)
        } else if let level = learnsetEntry as? BreedLearnsetEntry {
            self.init(breedLearnsetEntry: level)
        } else if let level = learnsetEntry as? TutorLearnsetEntry {
            self.init(tutorLearnsetEntry: level)
        } else {
            return nil
        }
    }

    init(levelLearnsetEntry: LevelLearnsetEntry) {
        let form = levelLearnsetEntry.form
        let pokemon = form.pokemon
        let level = levelLearnsetEntry.level
        let detailText = level >= 0 ? "Lv.\(NumberFormatter.twoDigit.string(from: NSNumber(value: level))!)" : "Evo."
        self.init(
            text: "\(NumberFormatter.threeDigit.string(from: NSNumber(value: pokemon.index))!) \(pokemon.name)",
            subtext: form.name == pokemon.name ? nil : form.name,
            detailText: detailText,
            image: UIImage(named: form.spriteName),
            pokemonForm: form)
    }

    init(machineLearnsetEntry: MachineLearnsetEntry) {
        let form = machineLearnsetEntry.form
        let pokemon = form.pokemon
        let machine = machineLearnsetEntry.machine
        let machineType = machine.type
        let detailText = "\(machineType.rawValue) \(NumberFormatter.twoDigit.string(from: NSNumber(value: machine.number))!)"
        self.init(
            text: "\(NumberFormatter.threeDigit.string(from: NSNumber(value: pokemon.index))!) \(pokemon.name)",
            subtext: form.name == pokemon.name ? nil : form.name,
            detailText: detailText,
            image: UIImage(named: form.spriteName),
            pokemonForm: form)
    }

    init(breedLearnsetEntry: BreedLearnsetEntry) {
        let form = breedLearnsetEntry.form
        let pokemon = form.pokemon
        self.init(
            text: "\(NumberFormatter.threeDigit.string(from: NSNumber(value: pokemon.index))!) \(pokemon.name)",
            subtext: form.name == pokemon.name ? nil : form.name,
            detailText: breedLearnsetEntry.fathers
                .compactMap { $0.name }
                .sorted()
                .joined(separator: ", "),
            image: UIImage(named: form.spriteName),
            pokemonForm: form)
    }

    init(tutorLearnsetEntry: TutorLearnsetEntry) {
        let form = tutorLearnsetEntry.form
        let pokemon = form.pokemon
        self.init(
            text: "\(NumberFormatter.threeDigit.string(from: NSNumber(value: pokemon.index))!) \(pokemon.name)",
            subtext: form.name == pokemon.name ? nil : form.name,
            detailText: nil,
            image: UIImage(named: form.spriteName),
            pokemonForm: form)
    }

}
