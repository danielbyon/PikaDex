//
//  DoneButton.swift
//  Pokedex
//
//  Created by Daniel Byon on 6/5/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct DoneButton: View {

    var isTrailing: Bool
    let action: () -> Void

    private var paddingEdges: Edge.Set {
        [Edge.Set.top, .bottom, isTrailing ? .leading : .trailing]
    }

    var body: some View {
        Button(action: self.action) {
            Text("Done")
                .bold()
                .padding(paddingEdges)
        }
    }

    init(isTrailing: Bool = true, action: @escaping () -> Void) {
        self.isTrailing = isTrailing
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
