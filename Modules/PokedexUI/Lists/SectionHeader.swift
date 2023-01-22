//
//  SectionHeader.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/23/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI

public struct SectionHeader: View {

    public let text: String

    public var body: some View {
        Text(text)
            .monospacedHeadline()
    }

    public init(_ text: String) {
        self.text = text
    }

}

struct SectionHeader_Previews: PreviewProvider {
    static var previews: some View {
        SectionHeader("Hello World")
    }
}
