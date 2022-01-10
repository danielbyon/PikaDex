//
//  TeamMember+PokemonForm.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/7/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

extension TeamMember {

    init(pokemonForm: PokemonForm, game: Game) {
        self.pokemon = pokemonForm.pokemon.name
        self.formName = pokemonForm.name
        self.nickname = ""
        self.level = 100
        self.hp = .init(baseValue: pokemonForm.baseStats.hp, ev: 0, iv: 0, isCalculated: true, value: 0)
        self.attack = .init(baseValue: pokemonForm.baseStats.attack, ev: 0, iv: 0, isCalculated: true, value: 0)
        self.defense = .init(baseValue: pokemonForm.baseStats.defense, ev: 0, iv: 0, isCalculated: true, value: 0)
        self.specialAttack = .init(baseValue: pokemonForm.baseStats.specialAttack, ev: 0, iv: 0, isCalculated: true, value: 0)
        self.specialDefense = .init(baseValue: pokemonForm.baseStats.specialDefense, ev: 0, iv: 0, isCalculated: true, value: 0)
        self.speed = .init(baseValue: pokemonForm.baseStats.speed, ev: 0, iv: 0, isCalculated: true, value: 0)
        self.ability = game.hasAbilities ? pokemonForm.primaryAbility?.name : nil
        self.game = game
        self.internalID = UUID()
    }

}
