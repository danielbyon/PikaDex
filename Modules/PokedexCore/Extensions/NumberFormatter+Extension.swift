//
//  File.swift
//  
//
//  Created by Daniel Byon on 12/18/19.
//

import Foundation

/// Immutable number-format styles shared across PikaDex presentation code.
///
/// `FormatStyle` values are safe to share across concurrency domains and avoid
/// the mutable global state carried by cached `NumberFormatter` instances.
public enum PokedexNumberFormat {

    public static let twoDigit = IntegerFormatStyle<Int>.number
        .grouping(.never)
        .precision(.integerLength(2))

    public static let pokemonIndex = IntegerFormatStyle<Int>.number
        .grouping(.never)
        .precision(.integerLength(3))

    public static let oneDecimal = FloatingPointFormatStyle<Double>.number
        .grouping(.never)
        .precision(.fractionLength(1))

    public static let wholeNumber = FloatingPointFormatStyle<Double>.number
        .grouping(.never)
        .precision(.fractionLength(0))
}
