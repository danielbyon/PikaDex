//
//  EggGroupsCell.swift
//  Pokedex
//
//  Created by Daniel Byon on 4/11/20.
//  Copyright © 2020 Daniel Byon. All rights reserved.
//

import SwiftUI

struct EggGroupsCell: View {

    let eggGroups: [EggGroup]

    var body: some View {
        HStack {
            Text("Egg Groups")
                .monospacedBody()
                .multilineTextAlignment(.leading)
            Spacer()
            ForEach(eggGroups, id: \.self) {
                Badge(eggGroup: $0)
            }
        }
        .padding(.vertical, 4.0)
    }

}

struct EggGroupsCell_Previews: PreviewProvider {
    static var previews: some View {
        EggGroupsCell(eggGroups: [.monster, .water1])
    }
}
