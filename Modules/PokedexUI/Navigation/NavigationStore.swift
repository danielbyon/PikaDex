//
//  NavigationStore.swift
//  Pokedex
//
//  Created by Daniel Byon on 9/9/22.
//  Copyright © 2022 Daniel Byon. All rights reserved.
//

import SwiftUI

/// Main-actor owner of the mutable navigation path consumed by SwiftUI.
@MainActor
public final class NavigationStore: ObservableObject {

    @Published public var path = NavigationPath()

    public init() { }

    public func clear() {
        path = .init()
    }

}
