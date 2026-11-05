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

/// Setup guidance for failures caused by a missing generated catalog resource.
public extension PersistenceBootstrapError {
    /// Returns the local generation command only when the bundled catalog is absent.
    var generatedDatabaseSetupInstruction: String? {
        guard case .locatingStore = stage,
              case .verifyBundledResources = recoveryContext,
              resourceName == "Pokedex.sqlite" else {
            return nil
        }
        return "Run Scripts/pokedex-data-pipeline generate, then rebuild the app."
    }
}

private final class PokedexCoreMarker { }
