//
//  BadgeCell.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/19/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct BadgeCell: View {

    let title: String
    var subtitle: String? = nil
    var image: UIImage? = nil
    var badge: Badge

    var body: some View {
        HStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40.0, height: 40.0)
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
            badge
        }
    }

    init(
        title: String,
        subtitle: String? = nil,
        image: UIImage? = nil,
        badge: Badge) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.badge = badge
    }

}

struct BadgeCell_Previews: PreviewProvider {
    static var previews: some View {
        BadgeCell(title: "Region", badge: Badge(region: .galar))
    }
}
