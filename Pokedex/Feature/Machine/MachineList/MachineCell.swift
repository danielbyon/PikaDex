//
//  MachineCell.swift
//  
//
//  Created by Daniel Byon on 10/22/22.
//

import PokedexUI
import SwiftUI

struct MachineCell: View {

    let machine: Machine

    var body: some View {
        HStack {
            MoveCell(move: machine.move)
            Text("\(machine.type.rawValue) \(PokedexNumberFormat.twoDigit.format(machine.number))")
                .monospacedBody()
        }
        .contentShape(Rectangle())
    }

}

struct MachineCell_Previews: PreviewProvider {
    static var previews: some View {
        MachineCell(machine: .tm01)
    }
}
