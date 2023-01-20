//
//  AppSetting.swift
//  
//
//  Created by Daniel Byon on 9/22/22.
//

import Foundation

public struct AppSetting<T> {
    public let key: String
}

extension AppSetting where T == Bool {

    public static let shouldUseMetersForHeight = AppSetting(key: "shouldUseMetersForHeight")

    public static let shouldUseKilogramsForWeight = AppSetting(key: "shouldUseKilogramsForWeight")

}

extension AppSetting where T: RawRepresentable, T.RawValue == String {

    public static var currentGame: AppSetting { AppSetting(key: "com.danielbyon.pokedex.currentGame") }

}

extension AppSetting where T == Data? {

    public static var pokemonDetailOrdering: AppSetting { AppSetting(key: "PokemonDetailOrdering") }

}
