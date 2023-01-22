//
//  Item.swift
//  
//
//  Created by Daniel Byon on 10/20/22.
//

import Foundation

public struct Item: Queryable {

    public typealias Filter = ItemFilter

    public let name: String
    public let game: Game
    public let generationIntroduced: Generation
    public let type: ItemType
    public let itemDescription: String
    public let spriteName: String
    public let info: ItemInfo
    public let bulbapediaURL: URL
    public let pokemonDBURL: URL?

    public enum ItemInfo {
        case bag(BagInfo)
        case berry(BerryInfo)
    }

    public struct BagInfo {

        public let itemDescription: String
        public let cost: Int?
        public let sell: Int?
        public let pocket: Pocket?

        public init(result: StoredBagItemInfo) {
            self.itemDescription = result.itemDescription
            self.cost = result.cost?.intValue
            self.sell = result.sell?.intValue
            self.pocket = result.pocket
        }

        public init(
            itemDescription: String,
            cost: Int? = nil,
            sell: Int? = nil,
            pocket: Pocket? = nil
        ) {
            self.itemDescription = itemDescription
            self.cost = cost
            self.sell = sell
            self.pocket = pocket
        }

    }

    public struct BerryInfo {

        public let itemDescription: String
        public let sizeInCm: Double
        public let firmness: BerryFirmness?
        public let bitter: Int
        public let dry: Int
        public let sour: Int
        public let spicy: Int
        public let sweet: Int

        public init(result: StoredBerryItemInfo) {
            self.itemDescription = result.itemDescription
            self.sizeInCm = result.sizeInCm
            self.firmness = result.firmness
            self.bitter = Int(result.bitter)
            self.dry = Int(result.dry)
            self.sour = Int(result.sour)
            self.spicy = Int(result.spicy)
            self.sweet = Int(result.sweet)
        }

        public init(
            itemDescription: String,
            sizeInCm: Double,
            firmness: BerryFirmness? = nil,
            bitter: Int,
            dry: Int,
            sour: Int,
            spicy: Int,
            sweet: Int
        ) {
            self.itemDescription = itemDescription
            self.sizeInCm = sizeInCm
            self.firmness = firmness
            self.bitter = bitter
            self.dry = dry
            self.sour = sour
            self.spicy = spicy
            self.sweet = sweet
        }

    }

    public init(result: StoredItem) {
        self.name = result.name
        self.game = result.game
        self.generationIntroduced = result.generationIntroduced
        self.type = result.itemType
        self.itemDescription = result.itemDescription
        self.spriteName = result.imageName
        switch result.itemType {
        case .item:
            self.info = .bag(.init(result: result.bagInfo!))
        case .berry:
            self.info = .berry(.init(result: result.berryInfo!))
        }
        self.bulbapediaURL = result.bulbapediaURL
        self.pokemonDBURL = result.pokemonDBURL
    }

    public init(
        name: String,
        game: Game,
        generationIntroduced: Generation,
        type: ItemType,
        itemDescription: String,
        spriteName: String,
        info: ItemInfo,
        bulbapediaURL: URL,
        pokemonDBURL: URL?
    ) {
        self.name = name
        self.game = game
        self.generationIntroduced = generationIntroduced
        self.type = type
        self.itemDescription = itemDescription
        self.spriteName = spriteName
        self.info = info
        self.bulbapediaURL = bulbapediaURL
        self.pokemonDBURL = pokemonDBURL
    }

}

extension Item: Codable { }

extension Item: Hashable { }

extension Item.ItemInfo: Codable { }

extension Item.ItemInfo: Hashable { }

extension Item.BagInfo: Codable { }

extension Item.BagInfo: Hashable { }

extension Item.BerryInfo: Codable { }

extension Item.BerryInfo: Hashable { }
