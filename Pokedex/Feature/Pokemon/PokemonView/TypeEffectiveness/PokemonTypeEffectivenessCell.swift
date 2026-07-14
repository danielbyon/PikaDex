//
//  PokemonTypeEffectivenessCell.swift
//  
//
//  Created by Daniel Byon on 9/28/22.
//

import PokedexUI
import SwiftUI

public struct PokemonTypeEffectivenessCell: View {

    let type: PokemonType
    let value: Double
    var equalWidths: Bool
    var isSmall: Bool

    private let quarterFractionCharacter = "\u{00BC}"
    private let halfFractionCharacter = "\u{00BD}"

    private var formattedValue: String {
        if value == 0 {
            return "0x"
        } else if value == 0.25 {
            return quarterFractionCharacter + "x"
        } else if value == 0.5 {
            return halfFractionCharacter + "x"
        } else {
            return value > 0 ? "\(PokedexNumberFormat.wholeNumber.format(value))x" : "0x"
        }
    }

    public var body: some View {
        HStack(spacing: 2.0) {
            Text(formattedValue)
                .font(.system(isSmall ? .caption : .body, design: .monospaced))
                .fontWeight(value != 1.0 ? .bold : .light)
            Badge(pokemonType: type, equalWidths: equalWidths, isSmall: isSmall)
        }
        .padding(.leading, 4.0)
        .background(
            RoundedRectangle(cornerRadius: 5.0)
                .stroke(lineWidth: 2.0)
                .foregroundColor(Color(type.color)))
    }

    public init(
        type: PokemonType,
        value: Double,
        equalWidths: Bool = true,
        isSmall: Bool = true
    ) {
        self.type = type
        self.value = value
        self.equalWidths = equalWidths
        self.isSmall = isSmall
    }

}

struct PokemonTypeEffectivenessCell_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PokemonTypeEffectivenessCell(type: .fire, value: 2.0)
            PokemonTypeEffectivenessCell(type: .fire, value: 0.25, equalWidths: false, isSmall: false)
        }
    }
}
