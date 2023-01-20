//
//  LocationInfoSection.swift
//  
//
//  Created by Daniel Byon on 10/19/22.
//

import PokedexUI
import SwiftUI

struct LocationInfoSection: View {

    let location: Location

    var body: some View {
        Section {
            Value1Cell(text: "Name", detailText: location.name)
            BadgeCell(title: "Region", badge: Badge(region: location.region))
        }
    }

}

