//
//  LengthFormatter+Extension.swift
//  Pokedex
//
//  Created by Daniel Byon on 2/25/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

extension LengthFormatter {

    /// Shared UI formatter. All access is confined to the main actor because
    /// `LengthFormatter` and its nested `NumberFormatter` are mutable classes.
    @MainActor public static let height: LengthFormatter = {
        let lengthFormatter = LengthFormatter()
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumIntegerDigits = 1
        numberFormatter.minimumFractionDigits = 1
        numberFormatter.maximumFractionDigits = 1
        lengthFormatter.numberFormatter = numberFormatter
        lengthFormatter.isForPersonHeightUse = true
        lengthFormatter.unitStyle = .short
        return lengthFormatter
    }()

}
