//
//  LocationMapPreview.swift
//  
//
//  Created by Daniel Byon on 10/19/22.
//

import PokedexUI
import SwiftUI

struct LocationMapPreview: View {

    let map: LocationMap

    var body: some View {
        if let image = map.image {
            GeometryReader { geo in
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width)
                    .clipped()
            }
        }
    }

}

//struct LocationMapPreview_Previews: PreviewProvider {
//    static var previews: some View {
//        LocationMapPreview(map: <#T##LocationMap#>)
//    }
//}
