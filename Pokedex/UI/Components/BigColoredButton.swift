//
//  BigColoredButton.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/14/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct BigColoredButton: View {

    var icon: Image? = nil
    let title: String
    var textColor: UIColor = .white
    let fillColor: UIColor

    private var cornerRadius: CGFloat { 16.0 }
    private var padding: CGFloat { 16.0 }

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color(fillColor))
                .shadow(radius: 3.0)
            HStack(alignment: .firstTextBaseline) {
                if icon != nil {
                    icon!
                }
                Text(title)
                    .multilineTextAlignment(.leading)
                    .shadow(radius: 0.5)
            }
            .font(.headline)
            .foregroundColor(Color(textColor))
            .padding(16.0)
        }
    }

}

struct BigColoredButton_Previews: PreviewProvider {
    static var previews: some View {
        BigColoredButton(title: "Hello World", fillColor: .systemGray)
    }
}
