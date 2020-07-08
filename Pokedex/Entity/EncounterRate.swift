//
//  EncounterRate.swift
//  Pokedex
//
//  Created by Daniel Byon on 3/17/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

public enum EncounterRate {
    case percent(Int)
    case rarity(EncounterRateRarity)
    case unknown

    init(rateType: EncounterRateType, rate: String) {
        switch rateType {
        case .percent:
            self = .percent(Int(rate) ?? 0)
        case .rarity:
            self = .rarity(EncounterRateRarity(rawValue: rate.lowercased()) ?? .common)
        case .unknown:
            self = .unknown
        }
    }
}

extension EncounterRate: Comparable {

    public static func < (lhs: EncounterRate, rhs: EncounterRate) -> Bool {
        switch (lhs, rhs) {
        case (.percent(let lPercent) ,.percent(let rPercent)):
            return lPercent < rPercent
        case (.rarity(let lRarity), .rarity(let rRarity)):
            return lRarity < rRarity
        case (.percent(let lPercent), .rarity(let rRarity)):
            return lPercent < rRarity.percent
        case (.rarity(let lRarity), .percent(let rPercent)):
            return lRarity.percent < rPercent
        case (.unknown, .unknown):
            return true
        default:
            return false
        }
    }

}

extension EncounterRate: Equatable {

    public static func == (lhs: EncounterRate, rhs: EncounterRate) -> Bool {
        switch (lhs, rhs) {
        case (.percent(let lPercent) ,.percent(let rPercent)):
            return lPercent == rPercent
        case (.rarity(let lRarity), .rarity(let rRarity)):
            return lRarity == rRarity
        case (.unknown, .unknown):
            return true
        default:
            return false
        }
    }

}

public enum EncounterRateType: String {
    case percent
    case rarity
    case unknown
}

public enum EncounterRateRarity: String, CaseIterable {

    case common
    case uncommon
    case rare
    case limited

    fileprivate var percent: Int {
        switch self {
        case .common:
            return 40
        case .uncommon:
            return 20
        case .rare:
            return 10
        case .limited:
            return 1
        }
    }

}

extension EncounterRateRarity: Comparable {

    public static func < (lhs: EncounterRateRarity, rhs: EncounterRateRarity) -> Bool {
        rhs.percent < rhs.percent
    }

}

extension EncounterRateRarity: Equatable { }
