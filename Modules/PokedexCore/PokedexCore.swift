//
//  PokedexCore.swift
//  
//
//  Created by Daniel Byon on 9/19/22.
//

@_exported import Foundation

extension Bundle {

    public static var pokedexCore: Bundle { Bundle(for: PokedexCoreMarker.self) }

}

private final class PokedexCoreMarker { }
