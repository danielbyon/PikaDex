//
//  View+Centering.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/22/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI

extension View {

    public func centered() -> some View {
        frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
    }

}
