//
//  Value1Cell.swift
//  Pokedex
//
//  Created by Daniel Byon on 2/19/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

public struct Value1Cell: View {

    let text: String
    var detailText: String?
    var image: Image?

    public var body: some View {
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

    public init(
        text: String,
        detailText: String? = nil,
        image: Image? = nil
    ) {
        self.text = text
        self.detailText = detailText
        self.image = image
    }

}

struct Value1MonospacedCell_Previews: PreviewProvider {
    static var previews: some View {
        Value1Cell(text: "Text", detailText: "Detail Text")
    }
}
