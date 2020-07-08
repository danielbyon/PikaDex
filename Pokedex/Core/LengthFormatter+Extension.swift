//
//  LengthFormatter+Extension.swift
//  Pokedex
//
//  Created by Daniel Byon on 2/25/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

extension LengthFormatter {

    static var height: LengthFormatter = {
        let lengthFormatter = LengthFormatter()
        lengthFormatter.numberFormatter = .heightWeight
        lengthFormatter.isForPersonHeightUse = true
        lengthFormatter.unitStyle = .short
        return lengthFormatter
    }()

}
