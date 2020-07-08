//
//  MachineType+Strings.swift
//  Pokedex
//
//  Created by Daniel Byon on 2/17/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

extension MachineType {

    var title: String {
        switch self {
        case .tm: return "TM"
        case .hm: return "HM"
        case .tr: return "TR"
        }
    }

}
