//
//  AppConstants.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/11/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import UIKit

enum AppConstants {

    static let tintColor = UIColor(red: 242 / 255, green: 68 / 255, blue: 80 / 255, alpha: 1)

    static var appName: String { Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "PocketPedia" }

    static var appVersion: String? { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String }

    static var buildVersion: String? { Bundle.main.infoDictionary?["CFBundleVersion"] as? String }

}
