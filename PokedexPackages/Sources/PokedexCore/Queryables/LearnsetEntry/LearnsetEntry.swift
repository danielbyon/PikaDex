//
//  LearnsetEntry.swift
//  
//
//  Created by Daniel Byon on 10/13/22.
//

import SwiftUI

public struct LearnsetEntry: Queryable {

    public typealias Filter = LearnsetEntryFilter

    public let text: String
    public let subtext: String?
    public let detailText: String?
    public let imageName: String?
    public let pokemonForm: LearnsetPokemonForm
    public let move: Move
    public let game: Game

    public init(result: StoredLearnsetEntry) {
        switch result.learnsetType {
        case .level:
            let level = result.level
            let form = LearnsetPokemonForm(result: result.form)
//            let move = Move(result: result.move)
            let detailText = level >= 0 ? "Lv.\(NumberFormatter.twoDigit.string(from: NSNumber(value: level))!)" : "Evo."

            self.init(
                text: "\(NumberFormatter.pokemonIndex.string(from: NSNumber(value: form.index))!) \(form.name)",
                subtext: form.name == form.formName ? nil : form.formName,
                detailText: detailText,
                imageName: form.spriteName,
                pokemonForm: form,
                move: .init(result: result.move),
                game: form.game
            )
        case .machine:
            let form = LearnsetPokemonForm(result: result.form)
            let machine = result.machine!
            let number = machine.number
            let type = machine.type
//            let move = Move(result: machine.move)
            let detailText = "\(type.rawValue) \(NumberFormatter.twoDigit.string(from: NSNumber(value: number))!)"

            self.init(
                text: "\(NumberFormatter.pokemonIndex.string(from: NSNumber(value: form.index))!) \(form.name)",
                subtext: form.name == form.formName ? nil : form.formName,
                detailText: detailText,
                imageName: form.spriteName,
                pokemonForm: form,
                move: .init(result: result.move),
                game: form.game
            )
        case .breeding:
            let form = LearnsetPokemonForm(result: result.form)
//            let move = Move(result: result.move)
//            let fathers = result.fathers.map(LearnsetBreedingFather.init)

            self.init(
                text: "\(NumberFormatter.pokemonIndex.string(from: NSNumber(value: form.index))!) \(form.name)",
                subtext: form.name == form.formName ? nil : form.formName,
                detailText: result.fathers
                    .compactMap { $0.name }
                    .sorted()
                    .joined(separator: ", "),
                imageName: form.spriteName,
                pokemonForm: form,
                move: .init(result: result.move),
                game: form.game
            )
        case .tutoring:
            let form = LearnsetPokemonForm(result: result.form)
//            let move = Move(result: result.move)

            self.init(
                text: "\(NumberFormatter.pokemonIndex.string(from: NSNumber(value: form.index))!) \(form.name)",
                subtext: form.name == form.formName ? nil : form.formName,
                detailText: nil,
                imageName: form.spriteName,
                pokemonForm: form,
                move: .init(result: result.move),
                game: form.game
            )
        }
    }

    public init(
        text: String,
        subtext: String?,
        detailText: String?,
        imageName: String?,
        pokemonForm: LearnsetPokemonForm,
        move: Move,
        game: Game
    ) {
        self.text = text
        self.subtext = subtext
        self.detailText = detailText
        self.imageName = imageName
        self.pokemonForm = pokemonForm
        self.move = move
        self.game = game
    }

}

extension LearnsetEntry: Identifiable {

    public var id: String { "\(text) \(pokemonForm.name) \(pokemonForm.formName) \(subtext ?? "") \(detailText ?? "") \(move.name) \(game.rawValue)" }

}
