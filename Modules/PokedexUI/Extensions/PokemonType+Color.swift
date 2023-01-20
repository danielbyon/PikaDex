//
//  Type+Color.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/17/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

#if os(iOS)

import UIKit

extension PokemonType {

    public var color: UIColor {
        switch self {
        case .bug:
            return UIColor(red: 168.0 / 255.0, green: 184.0 / 255.0, blue: 32.0 / 255.0, alpha: 1.0)
        case .dark:
            return UIColor(red: 112.0 / 255.0, green: 88.0 / 255.0, blue: 72.0 / 255.0, alpha: 1.0)
        case .dragon:
            return UIColor(red: 112.0 / 255.0, green: 56.0 / 255.0, blue: 248.0 / 255.0, alpha: 1.0)
        case .electric:
            return UIColor(red: 248.0 / 255.0, green: 208.0 / 255.0, blue: 48.0 / 255.0, alpha: 1.0)
        case .fairy:
            return UIColor(red: 238.0 / 255.0, green: 153.0 / 255.0, blue: 172.0 / 255.0, alpha: 1.0)
        case .fighting:
            return UIColor(red: 192.0 / 255.0, green: 48.0 / 255.0, blue: 40.0 / 255.0, alpha: 1.0)
        case .fire:
            return UIColor(red: 240.0 / 255.0, green: 128.0 / 255.0, blue: 48.0 / 255.0, alpha: 1.0)
        case .flying:
            return UIColor(red: 168.0 / 255.0, green: 144.0 / 255.0, blue: 204.0 / 255.0, alpha: 1.0)
        case .ghost:
            return UIColor(red: 112.0 / 255.0, green: 88.0 / 255.0, blue: 152.0 / 255.0, alpha: 1.0)
        case .grass:
            return UIColor(red: 120.0 / 255.0, green: 200.0 / 255.0, blue: 80.0 / 255.0, alpha: 1.0)
        case .ground:
            return UIColor(red: 224.0 / 255.0, green: 192.0 / 255.0, blue: 104.0 / 255.0, alpha: 1.0)
        case .ice:
            return UIColor(red: 152.0 / 255.0, green: 216.0 / 255.0, blue: 216.0 / 255.0, alpha: 1.0)
        case .normal:
            return UIColor(red: 168.0 / 255.0, green: 168.0 / 255.0, blue: 120.0 / 255.0, alpha: 1.0)
        case .poison:
            return UIColor(red: 160.0 / 255.0, green: 64.0 / 255.0, blue: 160.0 / 255.0, alpha: 1.0)
        case .psychic:
            return UIColor(red: 248.0 / 255.0, green: 88.0 / 255.0, blue: 136.0 / 255.0, alpha: 1.0)
        case .rock:
            return UIColor(red: 184.0 / 255.0, green: 160.0 / 255.0, blue: 56.0 / 255.0, alpha: 1.0)
        case .steel:
            return UIColor(red: 184.0 / 255.0, green: 184.0 / 255.0, blue: 208.0 / 255.0, alpha: 1.0)
        case .water:
            return UIColor(red: 104.0 / 255.0, green: 144.0 / 255.0, blue: 240.0 / 255.0, alpha: 1.0)
        }
    }

}

#endif
