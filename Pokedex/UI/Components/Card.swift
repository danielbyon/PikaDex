//
//  Card.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/16/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct Card<Content>: View where Content: View {

    let content: Content

    var body: some View {
        GroupBox {
            content
                .foregroundColor(.primary)
        }
        .contentShape(Rectangle())
    }

    init(content: () -> Content) {
        self.content = content()
    }

}

struct Card_Previews: PreviewProvider {
    static var previews: some View {
        Card {
            Text("Hello World")
        }
    }
}
