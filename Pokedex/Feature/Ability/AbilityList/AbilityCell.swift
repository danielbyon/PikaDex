//
//  AbilityCell.swift
//  
//
//  Created by Daniel Byon on 10/21/22.
//

import PokedexUI
import SwiftUI

public struct AbilityCell: View {

    let ability: Ability

    public var body: some View {
        Value1Cell(text: ability.name)
    }

    public init(ability: Ability) {
        self.ability = ability
    }

}

struct AbilityCell_Previews: PreviewProvider {
    static var previews: some View {
        AbilityCell(ability: .blaze)
    }
}
