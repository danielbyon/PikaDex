//
//  MassFormatter+Extension.swift
//  Pokedex
//
//  Created by Daniel Byon on 2/25/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

extension MassFormatter {

    /// Shared UI formatter. All access is confined to the main actor because
    /// `MassFormatter` and its nested `NumberFormatter` are mutable classes.
    @MainActor public static let weight: MassFormatter = {
        let massFormatter = MassFormatter()
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumIntegerDigits = 1
        numberFormatter.minimumFractionDigits = 1
        numberFormatter.maximumFractionDigits = 1
        massFormatter.numberFormatter = numberFormatter
        return massFormatter
    }()

}
