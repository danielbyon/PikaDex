//
//  Badge.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/17/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI

struct Badge: View {

    let title: String
    let fillColor: UIColor
    var equalWidths = false
    var isSmall = false

    var body: some View {
        Group {
            if equalWidths {
                ZStack {
                    Text("        ") // 8 spaces
                        .titleFont(isSmall: isSmall)
                        .badgeBackground(fillColor: fillColor)
                    titleText
                }
            } else {
                titleText
                    .badgeBackground(fillColor: fillColor)
            }
        }
    }

    private var titleText: some View {
        Text(title.uppercased())
            .titleFont(isSmall: isSmall)
            .foregroundColor(.white)
            .shadow(color: .black, radius: 0.5, x: 0.5, y: 0.5)
    }

}

extension Badge: Equatable {

    static func == (lhs: Badge, rhs: Badge) -> Bool {
        lhs.title == rhs.title
            && lhs.fillColor == rhs.fillColor
            && lhs.equalWidths == rhs.equalWidths
            && lhs.isSmall == rhs.isSmall
    }

}

extension Badge: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(fillColor)
        hasher.combine(equalWidths)
        hasher.combine(isSmall)
    }

}

private extension View {

    func titleFont(isSmall: Bool) -> some View {
        font(Font.system(isSmall ? .caption : .body, design: .monospaced).bold())
    }

    func badgeBackground(fillColor: UIColor) -> some View {
        padding(.horizontal, 5.0)
            .padding(.vertical, 1.0)
            .background(
                RoundedRectangle(cornerRadius: 5.0)
                    .fill(Color(fillColor)))
    }

}

extension Badge {

    init(pokemonType: PokemonType, equalWidths: Bool = false, isSmall: Bool = false) {
        self.title = pokemonType.rawValue
        self.fillColor = pokemonType.color
        self.equalWidths = equalWidths
        self.isSmall = isSmall
    }

    init(moveCategory: MoveCategory, equalWidths: Bool = false, isSmall: Bool = false) {
        self.title = moveCategory.title
        self.fillColor = moveCategory.uiColor
        self.equalWidths = equalWidths
        self.isSmall = isSmall
    }

    init(eggGroup: EggGroup, equalWidths: Bool = false, isSmall: Bool = false) {
        self.title = eggGroup.title
        self.fillColor = eggGroup.uiColor
        self.equalWidths = equalWidths
        self.isSmall = isSmall
    }

    init(region: Region, equalWidths: Bool = false) {
        self.init(title: region.name, fillColor: region.color, equalWidths: equalWidths)
    }

    init(encounterRate: EncounterRate) {
        let title: String
        let fillColor: UIColor
        switch encounterRate {
        case .percent(let percent):
            title = "\(percent)%"
            if percent < 10 {
                fillColor = #colorLiteral(red: 1.0, green: 0.165, blue: 0.225, alpha: 1.0)
            } else if percent == 10 {
                fillColor = #colorLiteral(red: 1.0, green: 0.464, blue: 0.0, alpha: 1.0)
            } else if percent < 20 {
                fillColor = #colorLiteral(red: 1.0, green: 0.865, blue: 0.181, alpha: 1.0)
            } else if percent < 30 {
                fillColor = #colorLiteral(red: 0.537, green: 0.912, blue: 0.0, alpha: 1.0)
            } else {
                fillColor = #colorLiteral(red: 0.0, green: 0.822, blue: 0.302, alpha: 1.0)
            }
        case .rarity(let rarity):
            title = rarity.rawValue
            switch rarity {
            case .common:
                fillColor = #colorLiteral(red: 0.0, green: 0.822, blue: 0.302, alpha: 1.0)
            case .uncommon:
                fillColor = #colorLiteral(red: 1.0, green: 0.865, blue: 0.181, alpha: 1.0)
            case .rare:
                fillColor = #colorLiteral(red: 1.0, green: 0.165, blue: 0.225, alpha: 1.0)
            case .limited:
                fillColor = #colorLiteral(red: 0.451, green: 0.451, blue: 0.451, alpha: 1.0)
            }
        case .unknown:
            title = "Unknown"
            fillColor = #colorLiteral(red: 0.451, green: 0.451, blue: 0.451, alpha: 1)
        }
        self.init(title: title, fillColor: fillColor)
    }

}

struct Badge_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading) {
            Badge(pokemonType: .ice)
            Badge(moveCategory: .status)
            Badge(moveCategory: .status, equalWidths: true)
            Badge(region: .kanto)
        }
    }
}
