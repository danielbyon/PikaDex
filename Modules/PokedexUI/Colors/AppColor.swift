//
//  AppColor.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/9/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

public enum AppColor: String {

    case brown
    case green
    case gray
    case orange
    case yellow
    case teal
    case blue
    case purple
    case pink
    case red

    public var uiColor: UIColor { UIColor(named: "App/\(rawValue)", in: .main, compatibleWith: nil)! }

    public var color: Color { Color(uiColor) }

}
