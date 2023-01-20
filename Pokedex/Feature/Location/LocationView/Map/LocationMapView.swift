//
//  LocationMapView.swift
//  
//
//  Created by Daniel Byon on 10/19/22.
//

import PokedexUI
import SwiftUI

struct LocationMapView: View {

    let map: LocationMap

    @Environment(\.dismiss) private var dismiss

    private var image: UIImage? { map.image }
    private var title: String { map.areaName }

    var body: some View {
        PannableZoomableImageView(image: image)
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    DoneButton(action: dismiss.callAsFunction)
                }
            }
    }

}

//struct LocationMapView_Previews: PreviewProvider {
//    static var previews: some View {
//        LocationMapView()
//    }
//}
