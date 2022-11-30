//
//  File.swift
//  
//
//  Created by Daniel Byon on 12/18/19.
//

import Foundation

extension NumberFormatter {

    public static let twoDigit: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    public static let pokemonIndex: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 3
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    public static let percent: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        formatter.positiveSuffix = "%"
        return formatter
    }()

    public static let heightWeight: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()

}
