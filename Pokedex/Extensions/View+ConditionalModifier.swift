//
//  View+ConditionalModifier.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/5/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

extension View {

    @ViewBuilder func conditionalModifier<Content>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View where Content: View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }

}
