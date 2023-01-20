//
//  OnFirstAppearModifier.swift
//  
//
//  Created by Daniel Byon on 9/28/22.
//

import SwiftUI

public struct OnFirstAppearModifier: ViewModifier {

    @State private var hasAppeared = false

    private let action: (() -> Void)?

    public func body(content: Content) -> some View {
        content
            .onAppear {
                guard !hasAppeared else { return }
                defer { hasAppeared = true }
                action?()
            }
    }

    public init(perform action: (() -> Void)? = nil) {
        self.action = action
    }

}

extension View {

    public func onFirstAppear(perform action: (() -> Void)? = nil) -> some View {
        return modifier(OnFirstAppearModifier(perform: action))
    }

}
