//
//  Badge+MoveCategory.swift
//  
//
//  Created by Daniel Byon on 9/28/22.
//

import DesignSystem

extension Badge {

    public init(moveCategory: MoveCategory, equalWidths: Bool = false, isSmall: Bool = false) {
        self.init(
            title: moveCategory.title,
            fillColor: moveCategory.uiColor,
            equalWidths: equalWidths,
            isSmall: isSmall
        )
    }

}
