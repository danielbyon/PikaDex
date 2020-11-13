//
//  SheetState.swift
//  Pokedex
//
//  Created by Daniel Byon on 10/31/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

class SheetState<State>: ObservableObject {

    @Published var isShowing = false

    @Published var state: State? {
        didSet { isShowing = state != nil }
    }

}
