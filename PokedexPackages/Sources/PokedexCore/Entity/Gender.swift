//
//  Gender.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/12/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

public enum Gender: String, CaseIterable, Codable, Hashable, Identifiable, Equatable {

    case male
    case female
    case unspecified

    public var id: String { rawValue }

}
