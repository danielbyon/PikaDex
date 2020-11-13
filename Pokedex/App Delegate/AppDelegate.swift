//
//  AppDelegate.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/11/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI
import UIKit
import CoreData

//@UIApplicationMain
//class AppDelegate: UIResponder, UIApplicationDelegate {
//
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        // Override point for customization after application launch.
//
//        UITableView.appearance().tableFooterView = UIView()
//        UITableView.appearance().separatorStyle = .none
//        UITableView.appearance().keyboardDismissMode = .interactive
//        UIScrollView.appearance().keyboardDismissMode = .interactive
//
//        return true
//    }
//
//    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
//        print(String(describing: userActivity))
//        return true
//    }
//
//    // MARK: UISceneSession Lifecycle
//
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }
//
//    override func buildMenu(with builder: UIMenuBuilder) {
//        super.buildMenu(with: builder)
//        builder.remove(menu: .help)
//    }
//
//}

@main
struct Pokedex: App {

    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .injectDependencies()
        }
    }

}

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        UITableView.appearance().tableFooterView = UIView()
//        UITableView.appearance().separatorStyle = .none
//        UITableView.appearance().keyboardDismissMode = .interactive
//        UIScrollView.appearance().keyboardDismissMode = .interactive

        if let container = makeCoreDataContainer() {
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

    private func makeCoreDataContainer() -> NSPersistentContainer? {
        let model = NSManagedObjectModel(contentsOf: Bundle.main.url(forResource: "Pokedex", withExtension: "momd")!.appendingPathComponent("Pokedex.mom"))!
        let container = NSPersistentContainer(name: "Pokedex", managedObjectModel: model)
        let url = Bundle.main.url(forResource: "Pokedex", withExtension: "sqlite")!
        let storeDescription = NSPersistentStoreDescription(url: url)
        storeDescription.isReadOnly = true
        container.persistentStoreDescriptions = [storeDescription]

        var capturedError: Error?
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            capturedError = error
            if let error = error as NSError? {
                debugPrint("Unresolved error \(error)")
            }
        })
        guard capturedError == nil else { return nil }
        return container
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
