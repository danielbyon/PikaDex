//
//  StatCell.swift
//  Pokedex
//
//  Created by Daniel Byon on 2/29/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct StatCell: View {

    let text: String
    let detailText: String

    var body: some View {
        VStack(spacing: 4.0) {
            Text(text)
                .underline()
                .monospacedSubheadline()
                .multilineTextAlignment(.leading)
            Text(detailText)
                .monospacedBody()
                .multilineTextAlignment(.leading)
        }
        .padding(.vertical, 4.0)
    }

}

struct StatCell_Previews: PreviewProvider {
    static var previews: some View {
        StatCell(text: "Introduced", detailText: "Generation 1")
    }
}
