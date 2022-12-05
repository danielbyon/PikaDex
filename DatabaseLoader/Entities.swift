//
//  Entities.swift
//  DatabaseLoader
//
//  Created by Daniel Byon on 4/26/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import PokedexCore

struct BulbapediaItem: Decodable {

    struct Price: Decodable {

        private enum CodingKeys: String, CodingKey {
            case rawCost = "cost"
            case rawSell = "sell"
        }

        private let rawCost: String
        private let rawSell: String

        var cost: Int? { Int(rawCost) }
        var sell: Int? { Int(rawSell) }

        init(cost: String, sell: String) {
            self.rawCost = cost
            self.rawSell = sell
        }

    }

    struct ItemInfo {
        let description: String?
        let pocket: Pocket?
        let price: Price?
    }

    let descriptions: [String: String]
    let generationIntroduced: String
    let imageName: String
    let name: String
    let pocket: [String: Pocket]
    let prices: [String: Price]?

    var generation: Generation {
        switch generationIntroduced {
        case "I": return .i
        case "II": return .ii
        case "III": return .iii
        case "IV": return .iv
        case "V": return .v
        case "VI": return .vi
        case "VII": return .vii
        case "VIII": return .viii
        case "IX": return .ix
        default: fatalError()
        }
    }

    func itemInfo(for game: Game) -> ItemInfo {
        let description = descriptions[game.rawValue]
        let pocket = pocket(for: game)
        let price = prices?[game.rawValue]
        return ItemInfo(description: description, pocket: pocket, price: price)
    }

    func pocket(for game: Game) -> Pocket? {
        if let pocket = pocket[game.rawValue] {
            return pocket
        } else if let pocket = pocket[game.generation.dictValue] {
            return pocket
        } else {
            return nil
        }
    }

}

struct BulbapediaBerry: Decodable {

    let index: String
    let name: String
    private let game: String
    private let generation: String
    private let sizeInCm: String?
    private let firmness: String?
    let description: String
    private let spicy: String?
    private let dry: String?
    private let sweet: String?
    private let bitter: String?
    private let sour: String?

    var berryGame: Game { Game(rawValue: game)! }
    var generationIntroduced: Generation { Generation(rawValue: Int(generation)!)! }
    var size: Double { sizeInCm != nil ? Double(sizeInCm!)! : -1 }
    var berryFirmness: BerryFirmness { BerryFirmness(rawValue: firmness!)! }
    var berrySpicy: Int16? { spicy != nil ? Int16(spicy!)! : nil }
    var berryDry: Int16? { dry != nil ? Int16(dry!)! : nil }
    var berrySweet: Int16? { sweet != nil ? Int16(sweet!)! : nil }
    var berryBitter: Int16? { bitter != nil ? Int16(bitter!)! : nil }
    var berrySour: Int16? { sour != nil ? Int16(sour!)! : nil }

}
