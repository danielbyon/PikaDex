//
//  Dependencies.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/11/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import CoreData
import Foundation
import PokedexCore
import SwiftUI

struct Dependencies: ViewModifier {

    static let settings = AppSettings()
    static let purchasedProductState = PurchasedProductState()
    static let storeViewModel = StoreViewModel()
    static let teamStorage = UserDefaults.appGroup
    static let teamStore = DefaultTeamStore.shared

    func body(content: Content) -> some View {
        content
            .environmentObject(Self.settings)
            .environmentObject(Self.purchasedProductState)
            .environmentObject(Self.storeViewModel)
            .injectPersistentContainer()
            .teamStorage(Self.teamStorage)
            .teamStore(Self.teamStore)
    }

}

extension View {

    func injectDependencies() -> some View {
        modifier(Dependencies())
    }

}
