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

    @AppGroupStorage(key: "com.danielbyon.pokedex.currentGame") var currentGame: Game = .sword {
        willSet {
            objectWillChange.send()
        }
    }

    @AppGroupStorage(key: "shouldUseMetersForHeight") var shouldUseMetersForHeight = true {
        willSet {
            objectWillChange.send()
        }
    }

    @AppGroupStorage(key: "shouldUseKilogramsForWeight") var shouldUseKilogramsForWeight = true {
        willSet {
            objectWillChange.send()
        }
    }

    private var subscription: AnyCancellable?

    private static let shouldUseMetersForHeightKey = "shouldUseMetersForHeight"
    private static let shouldUseKilogramsForWeightKey = "shouldUseKilogramsForWeight"

    init() {
        setupObserver()
    }

    private func setupObserver() {
        subscription = Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIApplication.willEnterForegroundNotification),
            NotificationCenter.default
                .publisher(for: UserDefaults.didChangeNotification)
        )
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] _ in
            self.objectWillChange.send()
        }
    }

}
