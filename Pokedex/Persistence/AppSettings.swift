//
//  AppSettings.swift
//  Pokedex
//
//  Created by Daniel Byon on 1/26/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI
import Combine
import AppSupport

final class AppSettings: ObservableObject {

    @UserDefault(key: "com.danielbyon.pokedex.currentGame", defaultValue: .sword, userDefaults: .appGroup) var currentGame: Game {
        willSet {
            objectWillChange.send()
        }
    }

    @AppStorage("shouldUseMetersForHeight", store: .appGroup) var shouldUseMetersForHeight = true

    @AppStorage("shouldUseKilogramsForWeight", store: .appGroup) var shouldUseKilogramsForWeight = true

    private var subscriptions = Set<AnyCancellable>()

    private static let shouldUseMetersForHeightKey = "shouldUseMetersForHeight"
    private static let shouldUseKilogramsForWeightKey = "shouldUseKilogramsForWeight"

    init() {
        setupObserver()
    }

    private func setupObserver() {
        subscriptions.insert(NotificationCenter.default
            .publisher(for: UIApplication.willEnterForegroundNotification)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                self.objectWillChange.send()
        })
        subscriptions.insert(NotificationCenter.default
            .publisher(for: UserDefaults.didChangeNotification)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                self.objectWillChange.send()
        })
    }

}
