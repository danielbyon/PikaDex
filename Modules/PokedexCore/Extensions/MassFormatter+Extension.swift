//
//  MassFormatter+Extension.swift
//  Pokedex
//
//  Created by Daniel Byon on 2/25/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

extension MassFormatter {

    public static let weight: MassFormatter = {
        let massFormatter = MassFormatter()
        massFormatter.numberFormatter = .heightWeight
        return massFormatter
    }()

}
