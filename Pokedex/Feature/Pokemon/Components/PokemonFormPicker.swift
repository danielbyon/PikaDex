//
//  PokemonFormPicker.swift
//  
//
//  Created by Daniel Byon on 9/22/22.
//

import PokedexUI
import SwiftUI

struct PokemonFormPicker: View {

    let forms: [PokemonDetailForm]
    let backgroundColor: Color
    @Binding var currentIndex: Int

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(0..<forms.count, id: \.self) { i in
                    Button {
                        currentIndex = i
                    } label: {
                        Image(forms[i].spriteName, bundle: .resources)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .padding(2)
                            .background(
                                RoundedRectangle(cornerRadius: 5.0)
                                    .stroke(lineWidth: i == currentIndex ? 2 : 0)
                                    .fill(backgroundColor)
                                    .animation(.default, value: currentIndex)
                            )
                            .padding(2)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

}

struct PokemonFormPicker_Previews: PreviewProvider {
    @State private static var currentIndex = 0

    static var previews: some View {
        PreviewContainer {
            List {
                PokemonFormPicker(
                    forms: [
                        .init(
                            name: "Charizard",
                            pokemonName: "Charizard",
                            baseExperienceYield: 0,
                            baseFriendship: 0,
                            color: .red,
                            familyName: "Charmander",
                            formIndex: 0,
                            game: .sword,
                            heightInMeters: 1.7,
                            index: 6,
                            pokedexEntry: "It spits fire that is hot enough to melt boulders. It may cause forest fires by blowing flames.",
                            primaryType: .fire,
                            secondaryType: nil,
                            species: "Flame",
                            weightInKilograms: 90.5,
                            spriteName: "006-menusprite",
                            baseStats: .init(
                                attack: 78,
                                defense: 84,
                                hp: 78,
                                specialAttack: 109,
                                specialDefense: 85,
                                speed: 100
                            ),
                            evolutions: [],
                            evYield: .init(
                                attack: 0,
                                defense: 0,
                                hp: 0,
                                specialAttack: 0,
                                specialDefense: 0,
                                speed: 0
                            ),
                            hiddenAbility: nil,
                            primaryAbility: nil,
                            secondaryAbility: nil,
                            pokedexNumbers: .init(national: 6, galar: 380)
                        ),
                        .init(
                            name: "Gigantamax Charizard",
                            pokemonName: "Charizard",
                            baseExperienceYield: 0,
                            baseFriendship: 0,
                            color: .red,
                            familyName: "Charmander",
                            formIndex: 1,
                            game: .sword,
                            heightInMeters: 1.7,
                            index: 6,
                            pokedexEntry: "It spits fire that is hot enough to melt boulders. It may cause forest fires by blowing flames.",
                            primaryType: .fire,
                            secondaryType: nil,
                            species: "Flame",
                            weightInKilograms: 90.5,
                            spriteName: "006-Gigantamax-Charizard-menusprite",
                            baseStats: .init(
                                attack: 78,
                                defense: 84,
                                hp: 78,
                                specialAttack: 109,
                                specialDefense: 85,
                                speed: 100
                            ),
                            evolutions: [],
                            evYield: .init(
                                attack: 0,
                                defense: 0,
                                hp: 0,
                                specialAttack: 0,
                                specialDefense: 0,
                                speed: 0
                            ),
                            hiddenAbility: nil,
                            primaryAbility: nil,
                            secondaryAbility: nil,
                            pokedexNumbers: .init(national: 6, galar: 380)
                        )
                    ],
                    backgroundColor: .red,
                    currentIndex: $currentIndex
                )
            }
        }
    }
}
