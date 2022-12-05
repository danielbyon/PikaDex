//
//  SelectPokemonFormAction.swift
//  
//
//  Created by Daniel Byon on 10/23/22.
//

import SwiftUI

public struct SelectPokemonFormAction {

    private let action: (PokemonDetailForm) -> Void

    init(action: @escaping (PokemonDetailForm) -> Void) {
        self.action = action
    }

    public func callAsFunction(_ pokemonForm: PokemonDetailForm) {
        action(pokemonForm)
    }

}

struct SelectPokemonFormActionKey: EnvironmentKey {

    static var defaultValue: SelectPokemonFormAction {
        .init { _ in
            debugPrint("No select pokemon form closure set")
        }
    }

}

extension EnvironmentValues {

    public var selectPokemonForm: SelectPokemonFormAction {
        get { self[SelectPokemonFormActionKey.self] }
        set { self[SelectPokemonFormActionKey.self] = newValue }
    }

}

extension View {

    public func onSelectPokemonForm(action: @escaping (PokemonDetailForm) -> Void) -> some View {
        environment(\.selectPokemonForm, .init(action: action))
    }

}
