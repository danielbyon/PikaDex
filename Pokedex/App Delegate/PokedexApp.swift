//
//  AppDelegate.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/11/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import PokedexCore
import SwiftUI
import UIKit

@main
struct PokedexApp: App {

    @Environment(\.scenePhase) private var scenePhase
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
                    UpdateMessageView()
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
