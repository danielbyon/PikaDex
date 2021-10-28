//
//  AppDelegate.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/11/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI
import UIKit

@main
struct PokedexApp: App {

    @State private var isShowingUpdateMessage = false
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate

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
            ContentView()
                .injectDependencies()
                .sheet(isPresented: $isShowingUpdateMessage) {
                    hasDisplayedUpdateMessage = true
                } content: {
                    UpdateMessage()
                }
                .onAppear {
                    if !hasDisplayedUpdateMessage {
                        isShowingUpdateMessage = true
                    }
                }
        }
    }

}

class AppDelegate: UIResponder, UIApplicationDelegate {

    let widgetAdapter = WidgetAdapter()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        migrateUserDefaultsIfNeeded()

        Dependencies.container = CoreDataManager().container

        DispatchQueue.main.async {
            InAppReviewManager.recordAppLaunch()
        }

        return true
    }

    private func migrateUserDefaultsIfNeeded() {
        let old = UserDefaults.standard
        let new = UserDefaults.appGroup

        let hasMigratedKey = "hasMigratedToAppGroup"

        guard !new.bool(forKey: hasMigratedKey) else {
            debugPrint("Already migrated defaults keys")
            return
        }

        let oldValues = old.dictionaryRepresentation()
        debugPrint(oldValues)

        for (key, value) in oldValues {
            new.set(value, forKey: key)
        }

        new.set(true, forKey: hasMigratedKey)
        debugPrint("Migrated defaults keys to app group suite")
    }

    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        builder.remove(menu: .help)
    }

}
