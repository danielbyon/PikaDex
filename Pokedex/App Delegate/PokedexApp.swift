//
//  AppDelegate.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/11/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import Dependencies
import AppSupport
import PokedexCore
import StoreKit
import SwiftUI
import UIKit

@main
struct PokedexApp: App {

    @Environment(\.scenePhase) private var scenePhase
    @State private var isShowingUpdateMessage = false
    /// These app-owned models are created once by SwiftUI and injected by identity
    /// into every dependency scope constructed for the root hierarchy.
    @StateObject private var appSettings: AppSettings
    @StateObject private var purchasedProductState: PurchasedProductState
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    private let persistenceStores: PersistenceStores
    private let teamStore: DefaultTeamStore
    private let storeClient: StoreClient

    init() {
        let appSettings = AppSettings()
        let purchasedProductState = PurchasedProductState()
        _appSettings = StateObject(wrappedValue: appSettings)
        _purchasedProductState = StateObject(wrappedValue: purchasedProductState)

        do {
            let persistenceStores = try PersistenceBootstrap.production()
            self.persistenceStores = persistenceStores
            teamStore = DefaultTeamStore(storage: UserDefaults.appGroup)
            storeClient = StoreClient(productIdentifiers: PokepediaProduct.allProducts)
        } catch {
            let message = [
                (error as? LocalizedError)?.errorDescription
                    ?? "PikaDex could not initialize its data stores.",
                (error as? PersistenceBootstrapError)?.generatedDatabaseSetupInstruction
            ]
            .compactMap { $0 }
            .joined(separator: "\n")
            debugPrint(message)
            fatalError(message)
        }
    }

    private var hasDisplayedUpdateMessage: Bool {
        get { UserDefaults.standard.bool(forKey: hasDisplayedUpdateMessageKey) }
        nonmutating set { UserDefaults.standard.set(newValue, forKey: hasDisplayedUpdateMessageKey) }
    }

    private var hasDisplayedUpdateMessageKey: String {
        if let appVersion = AppConstants.appVersion {
            return "hasDisplayedUpdateMessageForVersion-\(appVersion)"
        } else {
            assertionFailure()
            return "hasDisplayedUpdateMessageForVersion"
        }
    }

    var body: some Scene {
        WindowGroup {
            // Re-entering this closure during root-view recreation reuses the
            // StateObject-backed instances instead of constructing new defaults.
            withDependencies {
                $0.appSettings = appSettings
                $0.purchasedProductState = purchasedProductState
                $0.storeClient = storeClient
                $0.teamStore = teamStore
                $0.pokedexDataStore = persistenceStores.pokedex
                $0.userDataDataStore = persistenceStores.userData
            } operation: {
                ContentView()
                    .colorSchemeModifier()
                    .sheet(isPresented: $isShowingUpdateMessage) {
                        hasDisplayedUpdateMessage = true
                    } content: {
                        UpdateMessageView()
                            .colorSchemeModifier()
                    }
                    .onAppear {
                        if !hasDisplayedUpdateMessage {
                            isShowingUpdateMessage = true
                        }
                    }
                    .onChange(of: scenePhase) { newPhase in
                        if newPhase == .background {
                            teamStore.flushPendingWrites()
                        }
                    }
            }
        }
    }

}

class AppDelegate: UIResponder, UIApplicationDelegate {

    let widgetAdapter = WidgetAdapter()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        DispatchQueue.main.async {
            InAppReviewManager.recordAppLaunch()
        }

        return true
    }

    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        builder.remove(menu: .help)
    }

}

#if DEBUG
/// Explicit dependency composition for previews that construct app-owned views.
///
/// One container owns every reference for the lifetime of a preview hierarchy,
/// while each new preview root receives fresh volatile team storage.
@MainActor
struct PreviewDependencyRoot<Content: View>: View {

    @StateObject private var dependencies = PreviewDependencies()
    private let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        withDependencies {
            $0.appSettings = dependencies.appSettings
            $0.purchasedProductState = dependencies.purchasedProductState
            $0.storeClient = dependencies.storeClient
            $0.teamStore = dependencies.teamStore
        } operation: {
            content()
        }
    }
}

@MainActor
private final class PreviewDependencies: ObservableObject {
    let appSettings = AppSettings()
    let purchasedProductState = PurchasedProductState()
    let storeClient: any StoreClientProtocol = PreviewStoreClient()
    let teamStore = DefaultTeamStore(storage: VolatileTeamStorage())
}

private final class PreviewStoreClient: StoreClientProtocol {
    func requestProducts() async throws -> [SKProduct] { [] }
    func purchaseProduct(_ product: SKProduct) { }
    func restorePurchases() { }
}
#endif
