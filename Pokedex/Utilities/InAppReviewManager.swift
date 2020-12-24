//
//  InAppReviewManager.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/11/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import Foundation
import StoreKit
import AppSupport

struct InAppReviewManager {

    @AppGroupStorage(key: "appLaunchCount", defaultValue: 0)
    private static var appLaunchCount: Int

    @AppGroupStorage(key: "lastDateRequested", defaultValue: .distantPast)
    private static var lastDateRequested: Date

    private init() { }

    static func recordAppLaunch() {
        appLaunchCount += 1
        requestAppReviewIfNecessary()
    }

    private static func requestAppReviewIfNecessary() {
        guard appLaunchCount > 5,
            Date().timeIntervalSince(lastDateRequested) >= (30 * 86_400),
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        lastDateRequested = Date()
        SKStoreReviewController.requestReview(in: windowScene)
    }

}
