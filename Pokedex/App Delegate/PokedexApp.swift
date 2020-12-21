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

    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .injectDependencies()
        }
    }

}

class AppDelegate: UIResponder, UIApplicationDelegate {

    let widgetAdapter = WidgetAdapter()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        migrateUserDefaultsIfNeeded()

        if let container = CoreDataManager().container {
            Dependencies.container = container
            DispatchQueue.main.async {
                InAppReviewManager.recordAppLaunch()
            }
        } else {
            let viewController = UIViewController()
            let alert = makeErrorAlert()
            application.windows.first?.rootViewController = viewController
            DispatchQueue.main.async {
                viewController.present(alert, animated: true, completion: nil)
            }
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

    private func makeErrorAlert() -> UIAlertController {
        let controller = UIAlertController(
            title: "Unable to open database",
            message: "This could be because your device is out of disk space. Please manage your device's storage in the Settings app and re-launch \(AppConstants.appName).",
            preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Exit", style: .default) { _ in
            exit(0)
        })
        return controller
    }

    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        builder.remove(menu: .help)
    }

}
