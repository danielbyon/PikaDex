//
//  ColorSchemeModifier.swift
//  Pokedex
//
//  Created by Daniel Byon on 3/3/24.
//  Copyright © 2024 Daniel Byon. All rights reserved.
//

import SwiftUI

struct ColorSchemeModifier: ViewModifier {
    @AppStorage("preferredColorScheme") public var storedPreferredColorScheme = 0

    private var preferredColorScheme: ColorScheme? {
        switch storedPreferredColorScheme {
        case 1:
            return .light
        case 2:
            return .dark
        default:
            return nil
        }
    }

    func body(content: Content) -> some View {
        content
            .preferredColorScheme(preferredColorScheme)
    }
}

extension View {
    func colorSchemeModifier() -> some View {
        modifier(ColorSchemeModifier())
    }
}
