//
//  LocationMap+Image.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/1/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

extension LocationMap {

    var image: UIImage? {
        for namespace in location.game.imageNamespaces {
            let imageName = ["LocationMaps", namespace, filename].joined(separator: "/")
            if let image = UIImage(named: imageName) {
                return image
            }
        }
        return nil
    }

}

/*
B2W2
BW
Black
Black2
Crystal
DP
Emerald
FRLG
GSC
HGSS
ORAS
Platinum
RBY
RSE
Ruby
SM
Sapphire
USUM
White
White2
XY
Yellow
 */

private extension Game {

    var imageNamespaces: [String] {
        switch self {
        case .red,
             .blue:
            return ["RBY"]
        case .yellow:
            return ["Yellow", "RBY"]
        case .gold,
             .silver:
            return ["GSC"]
        case .crystal:
            return ["Crystal", "GSC"]
        case .ruby:
            return ["Ruby", "RSE"]
        case .sapphire:
            return ["Sapphire", "RSE"]
        case .emerald:
            return ["Emerald", "RSE"]
        case .fireRed,
             .leafGreen:
            return ["FRLG"]
        case .diamond,
             .pearl,
             .brilliantDiamond,
             .shiningPearl:
            return ["DP"]
        case .platinum:
            return ["Platinum", "DP"]
        case .heartGold,
             .soulSilver:
            return ["HGSS"]
        case .black:
            return ["Black", "BW"]
        case .white:
            return ["White", "BW"]
        case .black2:
            return ["Black2", "B2W2", "BW"]
        case .white2:
            return ["White2", "B2W2", "BW"]
        case .x,
             .y:
            return ["XY"]
        case .omegaRuby,
             .alphaSapphire:
            return ["ORAS"]
        case .sun,
             .moon:
            return ["SM"]
        case .ultraSun,
             .ultraMoon:
            return ["USUM"]
        case .letsGoPikachu,
             .letsGoEevee:
            return ["LGPLGE"]
        case .sword,
             .shield,
             .national:
            return ["SS"]
        }
    }

}
