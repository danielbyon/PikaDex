//
//  LocationMapDetail.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/29/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct LocationMapDetail: View {

    @Environment(\.presentationMode) var presentationMode

    let map: LocationMap

    private var image: UIImage? { map.image }
    private var title: String { map.areaName }

    var body: some View {
        PannableZoomableImageView(image: image)
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    DoneButton(action: dismiss)
                }
            }
    }

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }

}

struct LocationMapDetail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LocationMapDetail(map: Location.generateLocation(withName: "Route 1", region: .kanto, game: .red).maps[0])
        }
    }
}
