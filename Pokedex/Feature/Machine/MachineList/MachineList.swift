//
//  MachineList.swift
//  
//
//  Created by Daniel Byon on 10/21/22.
//

import PokedexUI
import SwiftUI

public struct MachineList: View {

    let title: String
    let game: Game

    @Query private var machines: QueryResults<Machine>
    @State private var selectedMachineType: MachineType = .tm

    private var segmentedControlValues: [MachineType] {
        var values: [MachineType] = []
        if !tms.isEmpty {
            values.append(.tm)
        }
        if !hms.isEmpty {
            values.append(.hm)
        }
        if !trs.isEmpty {
            values.append(.tr)
        }
        return values
    }
    private var tms: [Machine] { machines.filter { $0.type == .tm } }
    private var hms: [Machine] { machines.filter { $0.type == .hm } }
    private var trs: [Machine] { machines.filter { $0.type == .tr } }
    private var currentMachines: [Machine] {
        switch selectedMachineType {
        case .tm:
            return tms
        case .hm:
            return hms
        case .tr:
            return trs
        }
    }

    public var body: some View {
        List {
            ForEach(currentMachines, id: \.number) { machine in
                NavigationLink(value: Route.content(.move(machine.move))) {
                    MachineCell(machine: machine)
                }
            }
        }
        .toolbar {
            segmentedControl()
        }
        .listStyle(.plain)
        .navigationTitle(title)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {
                HomeButton()
            }
        }
        .onAppear {
            $machines.wrappedValue = .init(game: game)
        }
    }

    public init(title: String, game: Game) {
        self.title = title
        self.game = game
    }

    @ViewBuilder
    private func segmentedControl() -> some View {
        if segmentedControlValues.count > 1 {
            SegmentedControl(selectedSegment: $selectedMachineType, segments: segmentedControlValues)
        }
    }

}

struct MachineList_Previews: PreviewProvider {
    static var previews: some View {
        MachineList(
            title: "TMs / TRs",
            game: .sword
        )
    }
}
