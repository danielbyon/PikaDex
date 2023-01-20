//
//  Badge+EggGroup.swift
//  
//
//  Created by Daniel Byon on 9/28/22.
//

import DesignSystem

extension Badge {

    public init(eggGroup: EggGroup, equalWidths: Bool = false, isSmall: Bool = false) {
        self.init(
            title: eggGroup.title,
            fillColor: eggGroup.uiColor,
            equalWidths: equalWidths,
            isSmall: isSmall
        )
    }

}
