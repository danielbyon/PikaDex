//
//  DeleteButton.swift
//  Pokedex
//
//  Created by Daniel Byon on 12/10/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

public struct DeleteButton: View {

    var action: () -> Void

    public var body: some View {
        Button(action: action) {
            Image(systemName: "minus.circle.fill")
                .resizable()
                .foregroundColor(Color(.systemRed))
                .frame(width: 20.0, height: 20.0)
                .offset(x: 10.0, y: -10.0)
        }
    }

    public init(action: @escaping () -> Void) {
        self.action = action
    }

}

struct DeleteButton_Previews: PreviewProvider {
    static var previews: some View {
        DeleteButton(action: {})
    }
}
