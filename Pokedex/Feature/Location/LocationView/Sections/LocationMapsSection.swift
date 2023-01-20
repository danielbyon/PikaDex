//
//  LocationMapsSection.swift
//  
//
//  Created by Daniel Byon on 10/19/22.
//

import PokedexUI
import SwiftUI

struct LocationMapsSection: View {

    let maps: [LocationMap]

    @Binding var selectedMap: LocationMap?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    private var mapPreviewHeight: CGFloat { horizontalSizeClass == .regular ? 200.0 : 120.0 }
    private var mapPreviewPadding: CGFloat { 8.0 }

    var body: some View {
        Section {
            ForEach(maps, id: \.areaName) { map in
                VStack {
                    Text(map.areaName)
                        .monospacedBody()
                    LocationMapPreview(map: map)
                        .frame(height: mapPreviewHeight)
                }
                .padding(.vertical, mapPreviewPadding)
                .onTapGesture {
                    selectedMap = map
                }
            }
        } header: {
            SectionHeader("Maps")
        }
    }

}

//struct LocationMapsSection_Previews: PreviewProvider {
//    static var previews: some View {
//        LocationMapsSection()
//    }
//}
