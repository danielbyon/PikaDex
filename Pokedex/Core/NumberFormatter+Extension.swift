//
//  File.swift
//  
//
//  Created by Daniel Byon on 12/18/19.
//

import Foundation

public extension NumberFormatter {

    static let twoDigit: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    static let threeDigit: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 3
        formatter.maximumIntegerDigits = 3
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    static let percent: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        formatter.positiveSuffix = "%"
        return formatter
    }()

    static let heightWeight: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }()

}
