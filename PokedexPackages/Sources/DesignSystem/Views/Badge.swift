//
//  Badge.swift
//  Pokedex
//
//  Created by Daniel Byon on 11/17/19.
//  Copyright © 2019 Daniel Byon. All rights reserved.
//

import SwiftUI

public struct Badge: View {

    public let title: String
    public let fillColor: UIColor
    public let equalWidths: Bool
    public let isSmall: Bool

    public var body: some View {
        Group {
            if equalWidths {
                Text("        ") // 8 spaces
                    .titleFont(isSmall: isSmall)
                    .badgeBackground(fillColor: fillColor)
                    .overlay(titleText)
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

    public init(
        title: String,
        fillColor: UIColor,
        equalWidths: Bool = false,
        isSmall: Bool = false
    ) {
        self.title = title
        self.fillColor = fillColor
        self.equalWidths = equalWidths
        self.isSmall = isSmall
    }

}

extension Badge: Equatable {

    public static func == (lhs: Badge, rhs: Badge) -> Bool {
        lhs.title == rhs.title
            && lhs.fillColor == rhs.fillColor
            && lhs.equalWidths == rhs.equalWidths
            && lhs.isSmall == rhs.isSmall
    }

}

extension Badge: Hashable {

    public func hash(into hasher: inout Hasher) {
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

struct Badge_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading) {
            Badge(title: "Hello World", fillColor: .blue)
        }
    }
}
