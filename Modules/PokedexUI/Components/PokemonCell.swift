//
//  PokemonCell.swift
//  
//
//  Created by Daniel Byon on 9/20/22.
//

import PokedexCore
import SwiftUI

public struct PokemonCell: View {

    let name: String
    let formName: String?
    let number: String
    let primaryType: PokemonType
    let secondaryType: PokemonType?
    let spriteName: String

    public var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 4) {
                Sprite(spriteName, width: 40.0)
                Text(number)
                    .monospacedBody()
                    .frame(alignment: .trailing)
                VStack(alignment: .leading) {
                    Text(name)
                        .monospacedBody()
                    if let formName, formName != name {
                        Text(formName)
                            .monospacedCaption()
                    }
                }
                .frame(alignment: .leading)
            }

            Spacer(minLength: 2)

            VStack(spacing: 2) {
                Badge(pokemonType: primaryType, equalWidths: true, isSmall: true)
                if let secondaryType = secondaryType {
                    Badge(pokemonType: secondaryType, equalWidths: true, isSmall: true)
                }
            }
        }
        .contentShape(Rectangle())
    }

    public init(
        pokemon: Pokemon,
        pokedex: Pokedex
    ) {
        self.name = pokemon.name
        self.formName = nil
        self.number = pokemon.pokedexNumbers.formattedNumber(for: pokedex)
        self.primaryType = pokemon.primaryType
        self.secondaryType = pokemon.secondaryType
        self.spriteName = pokemon.spriteName
    }

    public init(pokemonForm: PokemonDetailForm) {
        self.name = pokemonForm.pokemonName
        self.formName = pokemonForm.name
        self.number = pokemonForm.pokedexNumbers.formattedNumber(for: .national)
        self.primaryType = pokemonForm.primaryType
        self.secondaryType = pokemonForm.secondaryType
        self.spriteName = pokemonForm.spriteName
    }

    public init(learnsetPokemonForm: LearnsetPokemonForm) {
        self.name = learnsetPokemonForm.name
        self.formName = learnsetPokemonForm.formName
        self.number = learnsetPokemonForm.pokedexNumbers.formattedNumber(for: .national)
        self.primaryType = learnsetPokemonForm.primaryType
        self.secondaryType = learnsetPokemonForm.secondaryType
        self.spriteName = learnsetPokemonForm.spriteName
    }

    public init(abilityPokemonForm: AbilityPokemonForm) {
        self.name = abilityPokemonForm.pokemonName
        self.formName = abilityPokemonForm.name
        number = abilityPokemonForm.pokedexNumbers.formattedNumber(for: .national)
        primaryType = abilityPokemonForm.primaryType
        secondaryType = abilityPokemonForm.secondaryType
        spriteName = abilityPokemonForm.spriteName
    }

}

struct ListPokemonCell_Previews: PreviewProvider {
    static var previews: some View {
        PokemonCell(
            pokemon: .charizard,
            pokedex: .national
        )
    }
}

private extension Pokemon {

    func formattedPokedexNumber(for pokedex: Pokedex) -> String {
        let number = NSNumber(value: number(for: pokedex))
        return NumberFormatter.pokemonIndex.string(from: number)!
    }

}
