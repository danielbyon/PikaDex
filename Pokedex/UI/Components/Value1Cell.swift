//
//  Value1Cell.swift
//  Pokedex
//
//  Created by Daniel Byon on 2/19/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct Value1Cell: View {

    let text: String
    var detailText: String? = nil
    var image: Image? = nil

    var body: some View {
        HStack {
            if let image = image {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40.0, height: 40.0)
            }
            HStack(alignment: .firstTextBaseline, spacing: 8.0) {
                Text(text)
                    .monospacedBody()
                    .multilineTextAlignment(.leading)
                Spacer()
                if let detailText = detailText {
                    Text(detailText)
                        .alignmentGuide(.trailing, computeValue: { d in d[.trailing] })
                        .monospacedBody()
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .contentShape(Rectangle())
    }

}

struct Value1MonospacedCell_Previews: PreviewProvider {
    static var previews: some View {
        Value1Cell(text: "Text", detailText: "Detail Text")
    }
}
