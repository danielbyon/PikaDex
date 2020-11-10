//
//  KeyboardAvoiderModifier.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/8/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

public struct KeyboardAvoiderModifier: ViewModifier {

    #if os(iOS)
    @StateObject var keyboardObserver = KeyboardObserver()
    #endif

    public func body(content: Content) -> some View {
        #if os(iOS)
        return content
            .padding(.bottom, keyboardObserver.keyboardHeight)
            .edgesIgnoringSafeArea(keyboardObserver.keyboardHeight > 0 ? .bottom : .init())
        #else
        return content
        #endif
    }

}

public extension View {

    func avoidKeyboard() -> some View {
        modifier(KeyboardAvoiderModifier())
    }

}
