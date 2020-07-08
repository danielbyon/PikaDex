//
//  AbilityViewModel.swift
//  Pokedex
//
//  Created by Daniel Byon on 2/29/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

struct AbilityViewModel {

    let text: String

    init(text: String) {
        self.text = text
    }

    init(ability: Ability) {
        self.init(text: ability.name)
    }

}
