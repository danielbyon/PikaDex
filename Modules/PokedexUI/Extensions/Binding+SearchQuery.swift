//
//  Binding+SearchQuery.swift
//  PokedexUI
//
//  Created by Daniel Byon on 1/20/24.
//  Copyright © 2024 Daniel Byon. All rights reserved.
//

import PokedexCore
import SwiftUI

extension Binding where Value == SearchQuery {
    public func toString() -> Binding<String> {
        return Binding<String> {
            switch wrappedValue {
            case .contains(let string):
                return string
            case .exact(let string):
                return string
            }
        } set: { newValue in
            switch wrappedValue {
            case .contains:
                self.wrappedValue = .contains(newValue)
            case .exact:
                self.wrappedValue = .exact(newValue)
            }
        }
    }
}
