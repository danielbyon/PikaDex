//
//  MacIcon.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/9/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct MacIcon: View {
    var body: some View {
        IconStack { canvas in
            Icon(canvas: canvas)
                .rotationEffect(.degrees(-9))
                .shadow(color: .black, radius: canvas[10], x: 0.0, y: canvas[-10])
        }
    }
}

struct MacIcon_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MacIcon()
                .previewIcon()
                .previewLayout(.sizeThatFits)
        }

    }
}
