//
//  AbilityCell.swift
//  Pokedex
//
//  Created by Daniel Byon on 2/29/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct AbilityCell: View {

    let model: AbilityViewModel

    var body: some View {
        Value1Cell(text: model.text)
    }

}

struct AbilityCell_Previews: PreviewProvider {
    static var previews: some View {
        AbilityCell(model: AbilityViewModel(text: "Blaze"))
    }
}
