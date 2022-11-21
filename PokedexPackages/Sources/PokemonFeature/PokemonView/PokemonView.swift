//
//  PokemonView.swift
//  
//
//  Created by Daniel Byon on 9/21/22.
//

import PokedexCore
import PokedexUI
import SwiftUI

public struct PokemonView: View {

    @Query private var pokemonDetailQuery: QueryResults<PokemonDetail>
    @State private var currentFormIndex = 0

    let pokedex: Pokedex
    let initialFormName: String?
    let pokemonDetailFilter: PokemonDetailFilter

    private var pokemonDetail: PokemonDetail? { pokemonDetailQuery.first }

    private var resolvedInitialFormName: String? {
        guard let initialFormName,
                let pokemonDetail,
                pokemonDetail.forms.contains(where: { $0.name == initialFormName }) else { return nil }
        return initialFormName
    }

    public var body: some View {
        Group {
            if let pokemonDetail {
                PokemonContentView(
                    currentFormIndex: $currentFormIndex,
                    viewModel: .init(
                        pokemon: pokemonDetail,
                        pokedex: pokedex
                    )
                )
            } else {
                Color.clear
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                HomeButton()
            }
        }
        .onAppear {
            $pokemonDetailQuery.wrappedValue = pokemonDetailFilter
        }
        .onChange(of: pokemonDetail) { newValue in
            updateCurrentFormIndexIfNecessary()
        }
    }

    public init(
        pokemon: Pokemon,
        pokedex: Pokedex,
        initialFormName: String? = nil
    ) {
        self.pokedex = pokedex
        self.initialFormName = initialFormName
        self.pokemonDetailFilter = .init(pokemon: pokemon)
    }

    public init(
        pokemonDetailForm: PokemonDetailForm,
        pokedex: Pokedex
    ) {
        self.pokedex = pokedex
        self.initialFormName = pokemonDetailForm.name
        self.pokemonDetailFilter = .init(name: pokemonDetailForm.pokemonName, game: pokemonDetailForm.game)
    }

    public init(
        abilityPokemonForm: AbilityPokemonForm,
        pokedex: Pokedex
    ) {
        self.pokedex = pokedex
        self.initialFormName = abilityPokemonForm.name
        self.pokemonDetailFilter = .init(name: abilityPokemonForm.pokemonName, game: abilityPokemonForm.game)
    }

    public init(
        evolutionPokemonForm: Evolution.PokemonForm,
        pokedex: Pokedex
    ) {
        self.pokedex = pokedex
        self.initialFormName = evolutionPokemonForm.formName
        self.pokemonDetailFilter = .init(name: evolutionPokemonForm.name, game: evolutionPokemonForm.game)
    }

    public init(
        learnsetPokemonForm: LearnsetPokemonForm
    ) {
        self.pokedex = .national
        self.initialFormName = learnsetPokemonForm.formName
        self.pokemonDetailFilter = .init(name: learnsetPokemonForm.name, game: learnsetPokemonForm.game)
    }

    private func updateCurrentFormIndexIfNecessary() {
        guard let initialFormName,
              let pokemonDetail,
              let formIndex = pokemonDetail.forms.firstIndex(where: { $0.name == initialFormName }) else {
            return
        }
        currentFormIndex = formIndex
    }

}
