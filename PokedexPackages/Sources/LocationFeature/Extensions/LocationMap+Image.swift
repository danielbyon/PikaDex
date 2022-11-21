//
//  LocationMap+Image.swift
//  
//
//  Created by Daniel Byon on 10/19/22.
//

import PokedexCore
import SwiftUI

extension LocationMap {

    var image: UIImage? {
        for namespace in game.imageNamespaces {
            let imageName = ["LocationMaps", namespace, filename].joined(separator: "/")
            if let image = UIImage(named: imageName) {
                return image
            }
        }
        return nil
    }

}

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
        case .legendsArceus:
            return ["LA"]
        }
    }

}

