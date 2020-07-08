//
//  SceneDelegate.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/11/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import UIKit
import SwiftUI
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        #if targetEnvironment(macCatalyst)
        windowScene.sizeRestrictions?.minimumSize = CGSize(width: 1440, height: 900)
        windowScene.sizeRestrictions?.maximumSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        #endif

        let window = UIWindow(windowScene: windowScene)

        if let container = makeCoreDataContainer() {
            Dependencies.container = container
            let contentView = ContentView()
                .injectDependencies()
            window.rootViewController = UIHostingController(rootView: contentView)

            DispatchQueue.main.async {
                InAppReviewManager.recordAppLaunch()
            }
        } else {
            let viewController = UIViewController()
            let alert = makeErrorAlert()
            window.rootViewController = viewController
            DispatchQueue.main.async {
                viewController.present(alert, animated: true, completion: nil)
            }
        }

        self.window = window
        window.makeKeyAndVisible()
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

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        NSUbiquitousKeyValueStore.default.synchronize()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

