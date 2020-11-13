//
//  View+ConditionalModifier.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/5/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

extension View {

    @ViewBuilder
    func `if`<Content: View>(
        _ condition: @autoclosure () -> Bool,
        content: (Self) -> Content) -> some View {
        if condition() {
            content(self)
        } else {
            self
        }
    }

    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: @autoclosure () -> Bool,
        if ifContent: (Self) -> TrueContent,
        else elseContent: (Self) -> FalseContent) -> some View {
        if condition() {
            ifContent(self)
        } else {
            elseContent(self)
        }
    }

    @ViewBuilder
    func ifLet<V, Content: View>(
        _ value: V?,
        content: (Self, V) -> Content) -> some View {
        if let value = value {
            content(self, value)
        } else {
            self
        }
    }

}
