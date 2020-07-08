//
//  LocationSectionHeader.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/20/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct LocationSectionHeader: View {

    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .monospacedHeadline()
            Text(subtitle)
                .monospacedCaption()
        }
    }

    init(section: LocationPokemonSection) {
        self.title = section.title
        if let detail = section.detail {
            self.subtitle = "\(section.subtitle) (\(detail))"
        } else {
            self.subtitle = section.subtitle
        }
    }

}

struct LocationSectionHeader_Previews: PreviewProvider {
    static var previews: some View {
        LocationSectionHeader(section: .init(
            title: "Den A",
            subtitle: "Wild Den",
            detail: "Common Pool",
            items: []))
    }
}
