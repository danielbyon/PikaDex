//
//  Badge+Region.swift
//  
//
//  Created by Daniel Byon on 9/28/22.
//

import DesignSystem

extension Badge {

    public init(region: Region, equalWidths: Bool = false) {
        self.init(title: region.name, fillColor: region.color, equalWidths: equalWidths)
    }

}
