//
//  NavigationStore.swift
//  Pokedex
//
//  Created by Daniel Byon on 9/9/22.
//  Copyright © 2022 Daniel Byon. All rights reserved.
//

import SwiftUI

public class NavigationStore: ObservableObject {

    @Published public var path = NavigationPath()

    public init() { }

    public func clear() {
        path = .init()
    }

}
