//
//  MobileIcon.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/9/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct MobileIcon: View {

    var body: some View {
        IconStack { canvas in
            Color.white
                .edgesIgnoringSafeArea(.all)
            Icon(canvas: canvas)
        }
    }
}

struct MobileIcon_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MobileIcon()
                .previewIcon()
                .previewLayout(.sizeThatFits)

            MobileIcon()
                .previewHomescreen()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.purple, .orange]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
            )
                .previewLayout(.fixed(width: 500, height: 500))
        }
    }
}
