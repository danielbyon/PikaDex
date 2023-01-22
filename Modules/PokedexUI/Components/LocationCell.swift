//
//  LocationCell.swift
//  
//
//  Created by Daniel Byon on 10/17/22.
//

import SwiftUI

public struct LocationCell: View {

    let location: Location

    public var body: some View {
        Text(location.name)
            .monospacedBody()
    }

    public init(location: Location) {
        self.location = location
    }

}

struct LocationCell_Previews: PreviewProvider {
    static var previews: some View {
        LocationCell(location: .galarMine)
    }
}
