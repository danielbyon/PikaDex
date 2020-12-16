//
//  Dependencies.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/11/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

struct Dependencies: ViewModifier {

    static let settings = AppSettings()
    static var container: NSPersistentContainer!
    static let purchasedProductState = PurchasedProductState()
    static let storeViewModel = StoreViewModel()

    func body(content: Content) -> some View {
        content
            .environment(\.managedObjectContext, Self.container!.viewContext)
            .environmentObject(Self.settings)
            .environmentObject(Self.purchasedProductState)
            .environmentObject(Self.storeViewModel)
    }

}

extension View {

    func injectDependencies() -> some View {
        modifier(Dependencies())
    }

}
