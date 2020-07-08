//
//  AppSettings.swift
//  Pokedex
//
//  Created by Daniel Byon on 1/26/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI
import Combine

final class AppSettings: ObservableObject {

    private static let shouldUseMetersForHeightKey = "shouldUseMetersForHeight"
    private static let shouldUseKilogramsForWeightKey = "shouldUseKilogramsForWeight"

    var shouldUseMetersForHeight: Bool {
        get { UserDefaults.standard.bool(forKey: Self.shouldUseMetersForHeightKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.shouldUseMetersForHeightKey); objectWillChange.send() }
    }

    var shouldUseKilogramsForWeight: Bool {
        get { UserDefaults.standard.bool(forKey: Self.shouldUseKilogramsForWeightKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.shouldUseKilogramsForWeightKey); objectWillChange.send() }
    }

    private var subscriptions = Set<AnyCancellable>()

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
