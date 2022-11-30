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

    public typealias PokemonProvider = (Int) -> Pokemon?

    @Query private var pokemonDetailQuery: QueryResults<PokemonDetail>
    @State private var currentFormIndex = 0

    let pokedex: Pokedex
    let initialFormName: String?
    let pokemonDetailFilter: PokemonDetailFilter
    private let previousPokemonProvider: PokemonProvider?
    private let nextPokemonProvider: PokemonProvider?

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
            ToolbarItemGroup {
                if let pokemonDetail {
                    if let previousPokemonProvider {
                        Button {
                            guard let pokemon = previousPokemonProvider(pokemonDetail.index) else { return }
                            $pokemonDetailQuery.wrappedValue = .init(pokemon: pokemon)
                            currentFormIndex = 0
                        } label: {
                            Image(systemName: "chevron.backward")
                        }
                        .disabled(previousPokemonProvider(pokemonDetail.index) == nil)
                    }
                    if let nextPokemonProvider {
                        Button {
                            guard let pokemon = nextPokemonProvider(pokemonDetail.index) else { return }
                            $pokemonDetailQuery.wrappedValue = .init(pokemon: pokemon)
                            currentFormIndex = 0
                        } label: {
                            Image(systemName: "chevron.forward")
                        }
                        .disabled(nextPokemonProvider(pokemonDetail.index) == nil)
                    }
                }
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
        self.previousPokemonProvider = nil
        self.nextPokemonProvider = nil
    }

    public init(
        pokemon: Pokemon,
        pokedex: Pokedex,
        previousPokemonProvider: PokemonProvider?,
        nextPokemonProvider: PokemonProvider?
    ) {
        self.pokedex = pokedex
        self.initialFormName = nil
        self.pokemonDetailFilter = .init(pokemon: pokemon)
        self.previousPokemonProvider = previousPokemonProvider
        self.nextPokemonProvider = nextPokemonProvider
    }

    public init(
        pokemonDetailForm: PokemonDetailForm,
        pokedex: Pokedex
    ) {
        self.pokedex = pokedex
        self.initialFormName = pokemonDetailForm.name
        self.pokemonDetailFilter = .init(name: pokemonDetailForm.pokemonName, game: pokemonDetailForm.game)
        self.previousPokemonProvider = nil
        self.nextPokemonProvider = nil
    }

    public init(
        abilityPokemonForm: AbilityPokemonForm,
        pokedex: Pokedex
    ) {
        self.pokedex = pokedex
        self.initialFormName = abilityPokemonForm.name
        self.pokemonDetailFilter = .init(name: abilityPokemonForm.pokemonName, game: abilityPokemonForm.game)
        self.previousPokemonProvider = nil
        self.nextPokemonProvider = nil
    }

    public init(
        evolutionPokemonForm: Evolution.PokemonForm,
        pokedex: Pokedex
    ) {
        self.pokedex = pokedex
        self.initialFormName = evolutionPokemonForm.formName
        self.pokemonDetailFilter = .init(name: evolutionPokemonForm.name, game: evolutionPokemonForm.game)
        self.previousPokemonProvider = nil
        self.nextPokemonProvider = nil
    }

    public init(
        learnsetPokemonForm: LearnsetPokemonForm
    ) {
        self.pokedex = .national
        self.initialFormName = learnsetPokemonForm.formName
        self.pokemonDetailFilter = .init(name: learnsetPokemonForm.name, game: learnsetPokemonForm.game)
        self.previousPokemonProvider = nil
        self.nextPokemonProvider = nil
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
