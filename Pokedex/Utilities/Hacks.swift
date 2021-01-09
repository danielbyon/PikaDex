//
//  Hacks.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/15/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI


@available(iOS, deprecated: 15, message: "Check if the DoubleColumn navigation view style bug still exists, that hides the back button when toolbars are used")
func emptyNavigationBarLeadingToolbarItemGroup() -> ToolbarItemGroup<Button<Text>> {
    ToolbarItemGroup(placement: .navigationBarLeading) {
        Button(" ", action: {})
    }
}
