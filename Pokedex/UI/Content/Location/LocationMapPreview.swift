//
//  LocationMapPreview.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/1/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct LocationMapPreview: View {

    let map: LocationMap

    var body: some View {
        GeometryReader { geo in
            Image(uiImage: self.map.image!)
                .resizable()
                .scaledToFit()
                .frame(width: geo.size.width)
                .clipped()
        }
    }

}

struct LocationMapPreview_Previews: PreviewProvider {
    static var previews: some View {
        LocationMapPreview(map: Location.generateLocation(withName: "Route 25", region: .kanto, game: .yellow).maps.first!)
    }
}
