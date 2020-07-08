//
//  LaunchIcon.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/10/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct LaunchIcon: View {
    var body: some View {
        IconStack { canvas in
            Icon(canvas: canvas)
        }
    }
}

struct LaunchIcon_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LaunchIcon()
            LaunchIcon()
                .environment(\.colorScheme, .dark)
        }
    }
}
