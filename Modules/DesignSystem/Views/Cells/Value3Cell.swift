//
//  Value3Cell.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/14/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

public struct Value3Cell: View {

    let title: String
    var subtitle: String?
    var detail: String?
    var image: UIImage?

    public var body: some View {
        HStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 40.0, height: 40.0)
                    .scaledToFit()
            }
            VStack(alignment: .leading, spacing: 2.0) {
                Text(title)
                    .monospacedBody()
                    .multilineTextAlignment(.leading)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .monospacedCaption()
                        .multilineTextAlignment(.leading)
                }
            }
            Spacer()
            if let detail = detail {
                Text(detail)
                    .alignmentGuide(.trailing, computeValue: { d in d[.trailing] })
                    .monospacedBody()
                    .multilineTextAlignment(.trailing)
            }
        }
        .contentShape(Rectangle())
    }

    public init(
        title: String,
        subtitle: String? = nil,
        detail: String? = nil,
        image: UIImage? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.detail = detail
        self.image = image
    }

}

struct Value3Cell_Previews: PreviewProvider {
    static var previews: some View {
        Value3Cell(title: "Charizard", subtitle: "Mega Charizard X", detail: "Level 01", image: UIImage(systemName: "square.and.arrow.up"))
    }
}
