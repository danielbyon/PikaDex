//
//  DoneButton.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/5/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

public struct DoneButton: View {

    let action: () -> Void

    public var body: some View {
        Button(action: action) {
            Text("Done")
        }
    }

    public init(action: @escaping () -> Void) {
        self.action = action
    }

}

struct DoneButton_Previews: PreviewProvider {
    static var previews: some View {
        DoneButton {
            print("Button tapped!")
        }
    }
}
