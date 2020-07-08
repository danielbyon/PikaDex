//
//  PokemonTypeEffectivenessCell.swift
//  Pokedex
//
//  Created by Daniel Byon on 5/29/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct PokemonTypeEffectivenessCell: View {

    let type: PokemonType
    let value: Double
    var equalWidths = true
    var isSmall = true

    private var formattedValue: String {
        if value == 0 {
            return "0x"
        } else if value == 0.25 {
            return "\u{00BC}" + "x"
        } else if value == 0.5 {
            return "\u{00BD}" + "x"
        } else {
            return value > 0 ? "\(Self.numberFormatter.string(from: NSNumber(value: value))!)x" : "0x"
        }
    }

    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.maximumIntegerDigits = 1
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    var body: some View {
        HStack(spacing: 2.0) {
            Text(formattedValue)
                .font(.system(isSmall ? .caption : .body, design: .monospaced))
                .bold()
            Badge(pokemonType: type, equalWidths: equalWidths, isSmall: isSmall)
        }
        .padding(.leading, 4.0)
        .background(
            RoundedRectangle(cornerRadius: 5.0)
                .stroke(lineWidth: 2.0)
                .foregroundColor(Color(type.color)))
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
