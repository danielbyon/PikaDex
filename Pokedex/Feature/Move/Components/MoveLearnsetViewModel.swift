//
//  MoveLearnsetViewModel.swift
//  
//
//  Created by Daniel Byon on 10/5/22.
//

import PokedexUI
import SwiftUI

struct MoveLearnsetViewModel {

    let text: String
    let subtext: String?
    let detailText: String?
    let image: UIImage?
    let pokemonForm: LearnsetPokemonForm

    init(learnsetEntry: PokedexCore.LearnsetEntry) {
        text = learnsetEntry.text
        subtext = learnsetEntry.subtext
        detailText = learnsetEntry.detailText
        if let imageName = learnsetEntry.imageName {
            image = UIImage(named: imageName, in: .resources, with: nil)
        } else {
            image = nil
        }
        pokemonForm = learnsetEntry.pokemonForm
    }

}

extension MoveLearnsetViewModel: Identifiable {

    var id: String { "\(text) \(pokemonForm.name) \(subtext ?? "") \(detailText ?? "")" }

}
