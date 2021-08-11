//
//  PokepediaProduct.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/11/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation

enum PokepediaProduct: String, CaseIterable {

    case all3DSGames = "com.danielbyon.pokepedia.iap.all3dsgames"
    case allDSGames = "com.danielbyon.pokepedia.iap.alldsgames"
    case allGameBoyGames = "com.danielbyon.pokepedia.iap.allgameboygames"
    case allSwitchGames = "com.danielbyon.pokepedia.iap.allswitchgames"
    case allGames = "com.danielbyon.pokepedia.iap.allgames"
    case generation1 = "com.danielbyon.pokepedia.iap.generation1"
    case generation2 = "com.danielbyon.pokepedia.iap.generation2"
    case rubySapphireEmerald = "com.danielbyon.pokepedia.iap.rubysapphireemerald"
    case fireRedLeafGreen = "com.danielbyon.pokepedia.iap.fireredleafgreen"
    case diamondPearlPlatinum = "com.danielbyon.pokepedia.iap.diamondpearlplatinum"
    case heartGoldSoulSilver = "com.danielbyon.pokepedia.iap.heartgoldsoulsilver"
    case blackWhite = "com.danielbyon.pokepedia.iap.blackwhite"
    case black2White2 = "com.danielbyon.pokepedia.iap.black2white2"
    case xY = "com.danielbyon.pokepedia.iap.xy"
    case omegaRubyAlphaSapphire = "com.danielbyon.pokepedia.iap.omegarubyalphasapphire"
    case sunMoon = "com.danielbyon.pokepedia.iap.sunmoon"
    case ultraSunUltraMoon = "com.danielbyon.pokepedia.iap.ultrasunultramoon"
    case letsGoPikachuLetsGoEevee = "com.danielbyon.pokepedia.iap.letsgopikachuletsgoeevee"
    case swordShield = "com.danielbyon.pokepedia.iap.swordshield"
    case smallTip = "com.danielbyon.pokepedia.iap.tipjarsmall"
    case mediumTip = "com.danielbyon.pokepedia.iap.tipjarmedium"
    case largeTip = "com.danielbyon.pokepedia.iap.tipjarlarge"

}

// MARK: - StoreKit
extension PokepediaProduct {

    var productIdentifier: ProductIdentifier { rawValue }

    var isTip: Bool {
        switch self {
        case .smallTip,
             .mediumTip,
             .largeTip:
            return true
        default:
            return false
        }
    }

    static let allProducts: Set<ProductIdentifier> = Set(PokepediaProduct.allCases.map { $0.productIdentifier })

    static let allConsoleProductsInOrder: [PokepediaProduct] = [
        .allGames,
        .allSwitchGames,
        .all3DSGames,
        .allDSGames,
        .allGameBoyGames
    ]

    static let allTipProductsInOrder: [PokepediaProduct] = [
        .smallTip,
        .mediumTip,
        .largeTip
    ]

    /// Discount values for applicable product identifiers, in percent
    static let allBundleDiscounts: [String: Int] = [
        Self.allGames.productIdentifier: 64,
        Self.all3DSGames.productIdentifier: 50,
        Self.allDSGames.productIdentifier: 50,
        Self.allGameBoyGames.productIdentifier: 50
    ]

    static let allBundleProducts: [PokepediaProduct: Set<PokepediaProduct>] = [
        .allGames: allGameProducts,
        .allSwitchGames: allSwitchProducts,
        .all3DSGames: allNintendo3DSProducts,
        .allDSGames: allNintendoDSProducts,
        .allGameBoyGames: allGameBoyProducts
    ]

    static let allSwitchProducts: Set<PokepediaProduct> = [
        .letsGoPikachuLetsGoEevee,
        .swordShield
    ]

    static let allNintendo3DSProducts: Set<PokepediaProduct> = [
        .xY,
        .omegaRubyAlphaSapphire,
        .sunMoon,
        .ultraSunUltraMoon
    ]

    static let allNintendoDSProducts: Set<PokepediaProduct> = [
        .diamondPearlPlatinum,
        .heartGoldSoulSilver,
        .blackWhite,
        .black2White2
    ]

    static let allGameBoyProducts: Set<PokepediaProduct> = [
        .generation1,
        .generation2,
        .rubySapphireEmerald,
        .fireRedLeafGreen
    ]

    static let allGameProducts: Set<PokepediaProduct> = [
        .generation1,
        .generation2,
        .rubySapphireEmerald,
        .fireRedLeafGreen,
        .diamondPearlPlatinum,
        .heartGoldSoulSilver,
        .blackWhite,
        .black2White2,
        .xY,
        .omegaRubyAlphaSapphire,
        .sunMoon,
        .ultraSunUltraMoon,
        .letsGoPikachuLetsGoEevee,
        .swordShield
    ]

    static let store = StoreClient(productIdentifiers: allProducts)

}

// MARK: - Purchase State
extension PokepediaProduct {

    var bitwiseValue: Int64 {
        var value: Int64 = 0
        switch self {
        case .all3DSGames:
            [Game.x,
             .y,
             .omegaRuby,
             .alphaSapphire,
             .sun,
             .moon,
             .ultraSun,
             .ultraMoon].forEach { value |= $0.bitwiseValue }
        case .allDSGames:
            [Game.diamond,
             .pearl,
             .platinum,
             .heartGold,
             .soulSilver,
             .black,
             .white,
             .black2,
             .white2].forEach { value |= $0.bitwiseValue }
        case .allGameBoyGames:
            [Game.red,
             .blue,
             .yellow,
             .gold,
             .silver,
             .crystal,
             .ruby,
             .sapphire,
             .emerald,
             .fireRed,
             .leafGreen].forEach { value |= $0.bitwiseValue }
        case .allSwitchGames:
            [Game.letsGoPikachu,
             .letsGoEevee,
             .sword,
             .shield].forEach { value |= $0.bitwiseValue }
        case .allGames:
            Game.allCases.forEach { value |= $0.bitwiseValue }
        case .generation1:
            Generation.i.games.forEach { value |= $0.bitwiseValue }
        case .generation2:
            Generation.ii.games.forEach { value |= $0.bitwiseValue }
        case .rubySapphireEmerald:
            [Game.ruby,
             .sapphire,
             .emerald].forEach { value |= $0.bitwiseValue }
        case .fireRedLeafGreen:
            [Game.fireRed,
             .leafGreen].forEach { value |= $0.bitwiseValue }
        case .diamondPearlPlatinum:
            [Game.diamond,
             .pearl,
             .platinum].forEach { value |= $0.bitwiseValue }
        case .heartGoldSoulSilver:
            [Game.heartGold,
             .soulSilver].forEach { value |= $0.bitwiseValue }
        case .blackWhite:
            [Game.black,
             .white].forEach { value |= $0.bitwiseValue }
        case .black2White2:
            [Game.black2,
             .white2].forEach { value |= $0.bitwiseValue }
        case .xY:
            [Game.x,
             .y].forEach { value |= $0.bitwiseValue }
        case .omegaRubyAlphaSapphire:
            [Game.omegaRuby,
             .alphaSapphire].forEach { value |= $0.bitwiseValue }
        case .sunMoon:
            [Game.sun,
             .moon].forEach { value |= $0.bitwiseValue }
        case .ultraSunUltraMoon:
            [Game.ultraSun,
             .ultraMoon].forEach { value |= $0.bitwiseValue }
        case .letsGoPikachuLetsGoEevee:
            [Game.letsGoPikachu,
             .letsGoEevee].forEach { value |= $0.bitwiseValue }
        case .swordShield:
            [Game.sword,
             .shield].forEach { value |= $0.bitwiseValue }
        case .smallTip,
             .mediumTip,
             .largeTip:
            break
        }
        return value
    }

    static var defaultPurchaseValue: Int64 { 0 }

}
