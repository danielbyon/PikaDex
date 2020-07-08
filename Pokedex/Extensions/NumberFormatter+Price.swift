//
//  NumberFormatter+Price.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/28/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

extension NumberFormatter {

    static func price(forLocale locale: Locale) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        return formatter
    }

}
