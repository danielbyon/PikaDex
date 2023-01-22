//
//  DescriptionCell.swift
//  Pokedex
//
//  Created by Daniel Byon on 2/29/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

public struct DescriptionCell: View {

    let text: String

    public var body: some View {
        HStack {
            Text(text)
                .monospacedBody()
                .multilineTextAlignment(.leading)
                .padding(.vertical, 4.0)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0.0)
        }
    }

    public init(text: String) {
        self.text = text
    }

}

struct DescriptionCell_Previews: PreviewProvider {
    static var previews: some View {
        DescriptionCell(text: "There is a plant seed on its back right from the day this Pokémon is born. The seed slowly grows larger.")
    }
}
