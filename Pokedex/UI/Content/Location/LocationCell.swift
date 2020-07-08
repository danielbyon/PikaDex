//
//  LocationCell.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/11/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct LocationCell: View {

    var location: Location

    var body: some View {
        HStack {
            Text(location.name)
                .monospacedBody()
            Spacer()
        }
        .contentShape(Rectangle())
    }
    
}

struct LocationCell_Previews: PreviewProvider {
    static var previews: some View {
        LocationCell(location: Location.generateGalarRoute1())
    }
}
