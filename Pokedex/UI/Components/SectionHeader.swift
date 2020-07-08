//
//  SectionHeader.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/23/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI

struct SectionHeader: View {

    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .monospacedHeadline()
    }
}

struct SectionHeader_Previews: PreviewProvider {
    static var previews: some View {
        SectionHeader("Hello World")
    }
}
